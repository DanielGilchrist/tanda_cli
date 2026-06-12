require "http"
require "uri"
require "log"

require "./fatal_error"
require "./network_error"
require "./result"

module TandaCLI
  module API
    class Request
      GET  = "GET"
      POST = "POST"

      INTERNAL_SERVER_ERROR_STRING = "Internal Server Error"

      alias Query = Hash(String, String)
      alias Body = Hash(String, String)

      def initialize(@base_uri : String, @token : String, @current_user : Current::User? = nil); end

      def get(type : T.class, endpoint : String, query : Query? = nil) : Result(T) forall T
        Result(T).from(exec(GET, endpoint, query: query))
      end

      def post(type : T.class, endpoint : String, body : Body) : Result(T) forall T
        Result(T).from(exec(POST, endpoint, body: body))
      end

      private def exec(method : String, endpoint : String, query : Query? = nil, body : Body? = nil) : HTTP::Client::Response
        with_no_internet_handler! do
          encoded_params = URI::Params.encode(query) if query
          uri = build_uri(endpoint, encoded_params)
          request_body = body.try(&.to_json)
          headers = build_headers

          HTTP::Client.exec(method, url: uri, headers: headers, body: request_body).tap do |response|
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

      private def to_parsed_pretty_json(string : String) : String
        begin
          JSON.parse(string)
        rescue JSON::ParseException
          string
        end.to_pretty_json
      end

      private def build_uri(endpoint, query : String? = nil) : URI
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

      private def with_no_internet_handler!(&)
        yield
      rescue Socket::Addrinfo::Error
        raise NetworkError.new("There appears to be a problem with your internet connection")
      end

      private def handle_fatal_error!(response : HTTP::Client::Response)
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
