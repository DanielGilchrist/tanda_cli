require "http"
require "json"

module Tanda::CLI
  module API
    class Auth
      def get_password_response(username : String, password : String)
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
