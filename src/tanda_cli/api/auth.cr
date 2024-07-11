# shards
require "http"
require "json"

# internal
require "../types/access_token"
require "../types/error"

module TandaCLI
  module API
    module Auth
      extend self

      VALID_SITE_PREFIXES = {"my", "eu", "us"}

      def fetch_new_token!
        config = Current.config
        site_prefix, email, password, scopes = request_user_information!

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

        access_token = fetch_access_token!(auth_site_prefix, email, password, scopes).or do |error|
          Utils::Display.error!("Unable to authenticate (likely incorrect login details)") do |sub_errors|
            sub_errors << "Error Type: #{error.error}\n"

            description = error.error_description
            sub_errors << "Message: #{description}" if description
          end
        end

        Utils::Display.success("Retrieved token!#{config.staging? ? " (staging)" : ""}\n")
        config.overwrite!(site_prefix, email, access_token)
      end

      private def fetch_access_token!(site_prefix : String, email : String, password : String, scopes : Array(Scopes::Scope)) : API::Result(Types::AccessToken)
        response = begin
          HTTP::Client.post(
            build_endpoint(site_prefix),
            headers: build_headers,
            body: {
              username:   email,
              password:   password,
              scope:      Scopes.join_to_api_string(scopes),
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

      private def request_user_information! : Tuple(String, String, String, Array(Scopes::Scope))
        selected_scopes = Scopes.prompt.multi_select("Which scopes do you want to allow? (Select none for all)")

        valid_site_prefixes = VALID_SITE_PREFIXES.join(", ")
        site_prefix = request_site_prefix(message: "Site prefix (#{valid_site_prefixes} - Default is \"my\"):")

        unless VALID_SITE_PREFIXES.includes?(site_prefix)
          Utils::Display.error!("Invalid site prefix") do |sub_errors|
            sub_errors << "Site prefix must be one of #{valid_site_prefixes}"
          end
        end
        puts

        email = Utils::Input.request_or(message: "Whats your email?") do
          Utils::Display.error!("Email cannot be blank")
        end
        puts

        password = Utils::Input.request_or(message: "What's your password?", sensitive: true) do
          Utils::Display.error!("Password cannot be blank")
        end
        puts

        {site_prefix, email, password, selected_scopes}
      end

      private def request_site_prefix(message : String) : String
        Utils::Input.request_or(message) do
          "my".tap do |default|
            Utils::Display.warning("Defaulting to \"#{default}\"")
          end
        end
      end
    end
  end
end
