module TandaCLI
  module Commands
    struct Auth
      @[Kebab::Command(summary: "Show current authentication status")]
      struct Status
        include Kebab::Parseable

        private alias Environment = Configuration::Serialisable::Environment

        def run(context : Context) : Nil
          display = context.display
          env = context.config.current

          unless context.authenticated?
            display.puts "🔒 #{"Not authenticated (#{env.display_label})".colorize.yellow}"
            display.puts "Run `tanda_cli auth login` to authenticate"
            return
          end

          access_token = env.access_token
          organisation = env.current_organisation?

          display.puts "🔓 #{"Authenticated (#{env.display_label})".colorize.green}"
          display.puts "📧 #{access_token.email}" if access_token
          display.puts "🏢 #{organisation.name} (user #{organisation.user_id})" if organisation

          case env
          in Environment::Production
            display.puts "🌐 #{env.region.display_name} (#{env.region.production_host})"
          in Environment::Staging
            display.puts "🌐 #{env.region.display_name} (#{env.region.staging_host})"
          in Environment::Custom
          end
        end
      end
    end
  end
end
