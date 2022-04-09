require "http"
require "json"

module Tanda::CLI
  module API
    class Auth
      def initialize(base_uri : String, email : String, password : String)
        @base_uri = base_uri
        @email = email
        @password = password
      end

      def get_access_token!
        HTTP::Client.post(
          "https://eu.tanda.co/api/oauth/token",
          headers: build_headers,
          body: {
            username:   username,
            password:   password,
            scope:      build_scopes,
            grant_type: "password"
          }.to_json
        )
        .body
      end

      private getter base_uri : String
      private getter email    : String
      private getter password : String

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
