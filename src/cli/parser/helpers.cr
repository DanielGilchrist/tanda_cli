module Tanda::CLI
  class CLI::Parser
    module Helpers
      private def build_client_with_current_user : API::Client
        client = create_client_from_config
        CLI::CurrentUser.new(client).set!

        client
      end

      private def maybe_display_staging_warning
        config = Current.config
        return unless config.staging?

        message = begin
          if (mode = config.mode) != "staging"
            "Command running on #{mode}"
          else
            "Command running in staging mode"
          end
        end

        Utils::Display.warning(message)
      end

      private def create_client_from_config : API::Client
        config = Current.config
        token = config.access_token.token

        # if a token can't be parsed from the config, get username and password from user and request a token
        if token.nil?
          fetch_new_token!
          return create_client_from_config
        end

        url = config.api_url
        API::Client.new(url, token)
      end

      private def fetch_new_token!
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

        access_token = API::Auth.fetch_access_token!(auth_site_prefix, email, password).or do |error|
          Utils::Display.error!("Unable to authenticate (likely incorrect login details)") do |sub_errors|
            sub_errors << "Error Type: #{error.error}\n"

            description = error.error_description
            sub_errors << "Message: #{description}" if description
          end
        end

        Utils::Display.success("Retrieved token!#{config.staging? ? " (staging)" : ""}\n")
        config.overwrite!(site_prefix, email, access_token)
      end
    end
  end
end
