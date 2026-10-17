module TandaCLI
  module Commands
    struct Auth
      @[Kebab::Command(summary: "Clear authentication for the current environment")]
      struct Logout
        include Kebab::Parseable

        def run(context : Context) : Nil
          display = context.display
          state = context.state

          revoke_access_token(display, state)

          label = state.current.display_label
          state.clear!
          state.save!

          display.success("Logged out of #{label} environment")
        end

        private def revoke_access_token(display : TandaCLI::Display, state : State) : Nil
          access_token = state.access_token
          return unless access_token

          display.info("Revoking access token...")
          response = HTTP::Client.post(
            state.current.oauth_url(:revoke),
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
