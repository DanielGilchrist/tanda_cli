# shards
require "http"
require "json"

# internal
require "../types/access_token"
require "../types/error"

module Tanda::CLI
  module API
    module Auth
      extend self

      def fetch_access_token!(site_prefix : String, email : String, password : String) : API::Result(Types::AccessToken)
        response = HTTP::Client.post(
          build_endpoint(site_prefix),
          headers: build_headers,
          body: {
            username:   email,
            password:   password,
            scope:      build_scopes,
            grant_type: "password",
          }.to_json
        )

        Log.debug(&.emit("Response", body: response.body))

        API::Result(Types::AccessToken).from(response)
      end

      private def build_endpoint(site_prefix : String) : String
        "https://#{site_prefix}.tanda.co/api/oauth/token"
      end

      private def build_headers : HTTP::Headers
        HTTP::Headers{
          "Cache-Control" => "no-cache",
          "Content-Type"  => "application/json",
        }
      end

      private def build_scopes : String
        {
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
          "platform",
        }
          .join(" ")
      end
    end
  end
end
