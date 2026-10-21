require "http"
require "uri"
require "log"

require "./fatal_error"
require "./network_error"
require "./result"
require "../spinner"

module TandaCLI
  module API
    class Request
      GET  = "GET"
      POST = "POST"
      PUT  = "PUT"

      INTERNAL_SERVER_ERROR_STRING = "Internal Server Error"

      FETCHING_MESSAGE = "Fetching…"
      SENDING_MESSAGE  = "Sending…"

      CONNECT_TIMEOUT = 10.seconds
      READ_TIMEOUT    = 30.seconds
      WRITE_TIMEOUT   = 10.seconds

      alias Query = Hash(String, String)
      alias Body = Hash(String, String)

      def initialize(@base_uri : String, @token : String, @current_user : Current::User? = nil) : Nil; end

      def get(type : T.class, endpoint : String, query : Query? = nil) : Result(T) forall T
        Result(T).from(exec(GET, endpoint, query: query))
      end

      def post(type : T.class, endpoint : String, body : Body | JSON::Serializable) : Result(T) forall T
        Result(T).from(exec(POST, endpoint, body: body.to_json))
      end

      def put(type : T.class, endpoint : String, body : JSON::Serializable) : Result(T) forall T
        Result(T).from(exec(PUT, endpoint, body: body.to_json))
      end

      private def exec(method : String, endpoint : String, query : Query? = nil, body : String? = nil) : HTTP::Client::Response
        with_network_error_handler! do
          encoded_params = URI::Params.encode(query) if query
          uri = build_uri(endpoint, encoded_params)
          request_body = body
          headers = build_headers

          Spinner.while_working(working_message(method)) { execute(method, uri, headers, request_body) }.tap do |response|
            Log.debug(&.emit(
              "#{method} response for #{endpoint}",
              headers: headers.pretty_inspect,
              query: encoded_params,
              body: request_body.try(&->to_parsed_pretty_json(String)),
              response: response.body.try(&->to_parsed_pretty_json(String)),
            ))

            handle_fatal_error!(response)
          end
        end
      end

      private def working_message(method : String) : String
        method == GET ? FETCHING_MESSAGE : SENDING_MESSAGE
      end

      private def execute(method : String, uri : URI, headers : HTTP::Headers, body : String?) : HTTP::Client::Response
        HTTP::Client.new(uri) do |client|
          client.connect_timeout = CONNECT_TIMEOUT
          client.read_timeout = READ_TIMEOUT
          client.write_timeout = WRITE_TIMEOUT

          client.exec(method, uri.request_target, headers: headers, body: body)
        end
      end

      private def to_parsed_pretty_json(string : String) : String
        begin
          JSON.parse(string)
        rescue JSON::ParseException
          string
        end.to_pretty_json
      end

      private def build_uri(endpoint : String, query : String? = nil) : URI
        uri = URI.parse("#{@base_uri}#{endpoint}")
        uri.query = query if query

        uri
      end

      private def build_headers : HTTP::Headers
        HTTP::Headers{
          "Authorization" => "Bearer #{@token}",
          "Content-Type"  => "application/json",
        }.tap do |headers|
          if user = @current_user
            headers["X-User-Id"] = user.id.to_s
          end
        end
      end

      private def with_network_error_handler!(& : -> HTTP::Client::Response) : HTTP::Client::Response
        yield
      rescue Socket::Addrinfo::Error
        raise NetworkError.new("There appears to be a problem with your internet connection")
      rescue IO::TimeoutError
        raise NetworkError.new("The request timed out, please try again")
      end

      private def handle_fatal_error!(response : HTTP::Client::Response) : Nil
        case response.status
        when .service_unavailable?
          raise FatalError.new("API is offline")
        when .internal_server_error?
          if response.body.includes?(INTERNAL_SERVER_ERROR_STRING)
            raise FatalError.new("An internal server error occured")
          end
        end
      end
    end
  end
end
