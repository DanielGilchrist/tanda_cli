module TandaCLI
  module Commands
    struct Auth
      @[Kebab::Command(summary: "Show current authentication status")]
      struct Status
        include Kebab::Parseable

        private alias Environments = State::Serialisable::Environments

        def run(context : Context) : Nil
          display = context.display
          env = context.state.current

          unless context.authenticated?
            display.puts "🔒 #{"Not authenticated (#{env.display_label})".colorize.yellow}"
            display.puts "Run `tanda_cli auth login` to authenticate"
            return
          end

          access_token = context.state.access_token
          organisation = context.state.current_organisation?

          display.puts "🔓 #{"Authenticated (#{env.display_label})".colorize.green}"
          display.puts "📧 #{access_token.email}" if access_token
          display.puts "🏢 #{organisation.name} (user #{organisation.user_id})" if organisation

          case env
          in Environments::Production
            display.puts "🌐 #{env.region.display_name} (#{env.region.production_host})"
          in Environments::Staging
            display.puts "🌐 #{env.region.display_name} (#{env.region.staging_host})"
          in Environments::Custom
          end
        end
      end
    end
  end
end
