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
          API::Auth.fetch_new_token!
          return create_client_from_config
        end

        url = config.api_url
        API::Client.new(url, token)
      end
    end
  end
end
