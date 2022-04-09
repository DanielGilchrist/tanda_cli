# shards
require "http"

module Tanda::CLI
  module API
    class Client
      def initialize(base_uri : String, token : String)
        @base_uri = base_uri
        @token = token
      end

      def get(endpoint : String)
        url = construct_url(endpoint)

        puts url
        HTTP::Client.get(url, headers: build_headers)
      end

      private getter base_uri  : String
      private getter token   : String

      private def construct_url(endpoint)
        "#{base_uri}#{endpoint}"
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
