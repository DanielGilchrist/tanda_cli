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

      alias TQuery = Hash(String, String)
      alias TBody = Hash(String, String)

      def initialize(base_uri : String, token : String)
        @base_uri = base_uri
        @token = token
      end

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

          execute_request! do |request_headers|
            HTTP::Client.exec(method, url: uri, headers: request_headers, body: request_body).tap do |response|
              Log.debug(&.emit(
                "#{method} response for #{endpoint}",
                headers: request_headers.pretty_inspect,
                query: encoded_params,
                body: request_body.try(&->to_parsed_pretty_json(String)),
                response: response.body.try(&->to_parsed_pretty_json(String)),
              ))

              handle_fatal_error!(response)
            end
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
          if user = Current.user?
            headers["X-User-Id"] = user.id.to_s
          end
        end
      end

      private def with_no_internet_handler!(&)
        yield
      rescue Socket::Addrinfo::Error
        Utils::Display.fatal!("There appears to be a problem with your internet connection")
      end

      private def execute_request!(&request : HTTP::Headers -> HTTP::Client::Response) : HTTP::Client::Response
        response = yield(build_headers)
        maybe_refetched_response = handle_invalid_token!(response, &request)

        maybe_refetched_response || response
      end

      private def handle_invalid_token!(response : HTTP::Client::Response, & : HTTP::Headers -> HTTP::Client::Response) : HTTP::Client::Response?
        return if response.status_code != 401

        message = "Your token is invalid, do you want to refetch a token and continue running the command? (y/n)"
        response = Utils::Input.request(message, display_type: :warning)
        return if response != "y"

        config = Current.config
        config.clear_access_token!

        API::Auth.fetch_new_token!

        token = config.access_token.token
        return if token.nil?

        @token = token
        yield(build_headers)
      end

      private def handle_fatal_error!(response : HTTP::Client::Response)
        case response.status
        when .service_unavailable?
          Utils::Display.fatal!("API is offline")
        when .internal_server_error?
          if response.body.includes?(INTERNAL_SERVER_ERROR_STRING)
            Utils::Display.fatal!("An internal server error occured")
          end
        end
      end
    end
  end
end
