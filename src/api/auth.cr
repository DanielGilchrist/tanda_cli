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

      def fetch_new_token!
        config = Current.config
        site_prefix, email, password = CLI::Auth.request_user_information!

        auth_site_prefix = begin
          if config.staging?
            case site_prefix
            when "my"
              "staging"
            when "eu"
              "staging.eu"
            when "us"
              "staging.us"
            end
          end
        end || site_prefix

        access_token = fetch_access_token!(auth_site_prefix, email, password).or do |error|
          Utils::Display.error!("Unable to authenticate (likely incorrect login details)") do |sub_errors|
            sub_errors << "Error Type: #{error.error}\n"

            description = error.error_description
            sub_errors << "Message: #{description}" if description
          end
        end

        Utils::Display.success("Retrieved token!#{config.staging? ? " (staging)" : ""}\n")
        config.overwrite!(site_prefix, email, access_token)
      end

      private def fetch_access_token!(site_prefix : String, email : String, password : String) : API::Result(Types::AccessToken)
        response = begin
          HTTP::Client.post(
            build_endpoint(site_prefix),
            headers: build_headers,
            body: {
              username:   email,
              password:   password,
              scope:      build_scopes,
              grant_type: "password",
            }.to_json
          )
        rescue Socket::Addrinfo::Error
          Utils::Display.fatal!("There appears to be a problem with your internet connection")
        end

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
