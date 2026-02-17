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

          config.reset_environment!
          config.save!

          environment = config.staging? ? "staging" : "production"
          display.success("Logged out of #{environment} environment")
        end

        private def revoke_access_token
          token = config.access_token.token
          return unless token

          url = config.oauth_url(:revoke)
          return unless url.is_a?(String)

          display.info("Revoking access token...")
          response = HTTP::Client.post(
            url,
            headers: HTTP::Headers{
              "Content-Type" => "application/json",
            },
            body: {token: token}.to_json,
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
