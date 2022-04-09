require "http"
require "json"

module Tanda::CLI
  module API
    class Auth
      def initialize(site_prefix : String, email : String, password : String)
        @site_prefix = site_prefix
        @email = email
        @password = password
      end

      def get_access_token! : String
        HTTP::Client.post(
          build_endpoint,
          headers: build_headers,
          body: {
            username:   email,
            password:   password,
            scope:      build_scopes,
            grant_type: "password"
          }.to_json
        )
        .body
      end

      private getter site_prefix : String
      private getter email    : String
      private getter password : String

      def build_endpoint : String
        "https://#{site_prefix}.tanda.co/api/oauth/token"
      end

      private def build_headers : HTTP::Headers
        HTTP::Headers{
          "Cache-Control" => "no-cache",
          "Content-Type" => "application/json"
        }
      end

      private def build_scopes : String
        [
          "me",
          "roster",
          "timesheet",
          "department",
          "user",
          "cost",
          "leave",
          "unavailability",
          "datastream",
          "device",
          "qualifications",
          "settings",
          "organisation",
          "sms",
          "personal",
          "financial",
          "platform"
        ]
        .join(" ")
      end
    end
  end
end
