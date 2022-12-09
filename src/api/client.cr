require "http"
require "uri"
require "log"

require "./endpoints"

module Tanda::CLI
  module API
    class Client
      include Tanda::CLI::API::Endpoints

      INTERNAL_SERVER_ERROR_STRING = "Internal Server Error"

      alias TQuery = Hash(String, String)
      alias TBody = Hash(String, String)

      def initialize(base_uri : String, token : String)
        @base_uri = base_uri
        @token = token
      end

      def get(endpoint : String, query : TQuery? = nil) : HTTP::Client::Response
        uri = build_uri(endpoint, query)
        headers = build_headers

        HTTP::Client.get(uri, headers: headers).tap do |response|
          Log.debug(&.emit("Response", headers: headers.to_s, response: response.body))
          handle_fatal_error!(response)
        end
      rescue Socket::Addrinfo::Error
        Utils::Display.fatal!("There appears to be a problem with your internet connection")
      end

      def post(endpoint : String, body : TBody) : HTTP::Client::Response
        uri = build_uri(endpoint)
        headers = build_headers
        request_body = body.to_json

        HTTP::Client.post(uri, headers: headers, body: request_body).tap do |response|
          Log.debug(&.emit("Response", headers: headers.to_s, body: request_body, response: response.body))
          handle_fatal_error!(response)
        end
      rescue Socket::Addrinfo::Error
        Utils::Display.fatal!("There appears to be a problem with your internet connection")
      end

      private getter base_uri : String
      private getter token : String

      private def build_uri(endpoint, query : TQuery? = nil) : URI
        uri = URI.parse("#{base_uri}#{endpoint}")
        uri.query = URI::Params.encode(query) if query

        uri
      end

      private def build_headers : HTTP::Headers
        HTTP::Headers{
          "Authorization" => "Bearer #{token}",
          "Content-Type"  => "application/json",
        }.tap do |headers|
          headers["X-User-Id"] = Current.user.id.to_s if Current.user?
        end
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
