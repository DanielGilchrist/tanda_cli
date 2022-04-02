# shards
require "http"

# internal
require "./configuration"

module Tanda::CLI
  module API
    class Client
      def initialize(token : String, config : Configuration)
        @token = token
        @config = config
        @api_url = config.get_api_url
      end

      def get(endpoint : String)
        url = construct_url(endpoint)
        headers = HTTP::Headers{
          "Authorization" => "Bearer #{token}",
          "Content-Type" => "application/json"
        }

        puts url
        HTTP::Client.get(url, headers: headers)
      end

      private getter token   : String
      private getter config  : Configuration
      private getter api_url : String

      private def construct_url(endpoint)
        "#{api_url}#{endpoint}"
      end
    end
  end
end
