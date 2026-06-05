module TandaCLI
  module Commands
    class Auth
      class Logout < Base
        def setup_
          @name = "logout"
          @summary = @description = "Clear authentication for the current environment"
        end

        def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
          revoke_access_token

          label = config.current.display_label
          config.reset_current_environment!
          config.save!

          display.success("Logged out of #{label} environment")
        end

        private def revoke_access_token
          access_token = config.access_token
          return unless access_token

          display.info("Revoking access token...")
          response = HTTP::Client.post(
            config.oauth_url(:revoke),
            headers: HTTP::Headers{
              "Content-Type" => "application/json",
            },
            body: {token: access_token.token}.to_json,
          )

          if response.success?
            display.success("Revoked access token")
          else
            display.warning("Failed to revoke token (status: #{response.status_code})")
          end
        rescue Socket::Addrinfo::Error
          display.warning("Failed to revoke token (network error)")
        end
      end
    end
  end
end
