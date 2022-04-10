require "http"
require "uri"

module Tanda::CLI
  module API
    class Client
      alias TQuery = Hash(String | String, String)?

      def initialize(base_uri : String, token : String)
        @base_uri = base_uri
        @token = token
      end

      def get(endpoint : String, query : TQuery = nil) : HTTP::Client::Response
        uri = construct_uri(endpoint, query)
        puts uri
        HTTP::Client.get(uri, headers: build_headers)
      end

      private getter base_uri : String
      private getter token    : String

      private def construct_uri(endpoint, query : TQuery = nil) : URI
        uri = URI.parse("#{base_uri}#{endpoint}")

        query_params = URI::Params.encode(query) if query
        uri.query = query_params if query_params

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
