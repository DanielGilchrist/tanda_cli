require "http"
require "uri"
require "log"

require "./endpoints"

module Tanda::CLI
  module API
    class Client
      include Tanda::CLI::API::Endpoints

      alias TQuery = Hash(String, String)

      def initialize(base_uri : String, token : String)
        @base_uri = base_uri
        @token = token
      end

      def get(endpoint : String, query : TQuery? = nil) : HTTP::Client::Response
        uri = build_uri(endpoint, query)

        response = HTTP::Client.get(uri, headers: build_headers)
        Log.debug(&.emit("Response", body: response.body))

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
        }
      end
    end
  end
end
