require "http"
require "uri"
require "log"

require "./endpoints"

module Tanda::CLI
  module API
    class Client
      include Tanda::CLI::API::Endpoints

      alias TQuery = Hash(String, String)
      alias TBody  = Hash(String, String)

      def initialize(base_uri : String, token : String)
        @base_uri = base_uri
        @token = token
      end

      def get(endpoint : String, query : TQuery? = nil) : HTTP::Client::Response
        uri = build_uri(endpoint, query)
        headers = build_headers

        response = HTTP::Client.get(uri, headers: headers)
        Log.debug(&.emit("Response", headers: headers.to_s, response: response.body))

        response
      end

      def post(endpoint : String, body : TBody) : HTTP::Client::Response
        uri = build_uri(endpoint)
        headers = build_headers
        request_body = body.to_json

        response = HTTP::Client.post(uri, headers: headers, body: request_body)
        Log.debug(&.emit("Response", headers: headers.to_s, body: request_body, response: response.body))

        response
      end

      private getter base_uri : String
      private getter token    : String

      private def build_uri(endpoint, query : TQuery? = nil) : URI
        uri = URI.parse("#{base_uri}#{endpoint}")
        uri.query = URI::Params.encode(query) if query

        uri
      end

      private def build_headers : HTTP::Headers
        HTTP::Headers{
          "Authorization" => "Bearer #{token}",
          "Content-Type" => "application/json"
        }.tap do |headers|
          headers["X-User-Id"] = Current.user.id.to_s if Current.user?
        end
      end
    end
  end
end
