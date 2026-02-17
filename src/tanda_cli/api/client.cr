require "http"
require "uri"
require "log"

require "./endpoints"

module TandaCLI
  module API
    class Client
      include Endpoints

      GET  = "GET"
      POST = "POST"

      INTERNAL_SERVER_ERROR_STRING = "Internal Server Error"

      class NetworkError < Exception; end

      class FatalAPIError < Exception; end

      alias TQuery = Hash(String, String)
      alias TBody = Hash(String, String)

      def initialize(@base_uri : String, @token : String, @current_user : Current::User? = nil); end

      def get(endpoint : String, query : TQuery? = nil) : HTTP::Client::Response
        exec(GET, endpoint, query: query)
      end

      def post(endpoint : String, body : TBody) : HTTP::Client::Response
        exec(POST, endpoint, body: body)
      end

      private def exec(method : String, endpoint : String, query : TQuery? = nil, body : TBody? = nil) : HTTP::Client::Response
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
          raise FatalAPIError.new("API is offline")
        when .internal_server_error?
          if response.body.includes?(INTERNAL_SERVER_ERROR_STRING)
            raise FatalAPIError.new("An internal server error occured")
          end
        end
      end
    end
  end
end
