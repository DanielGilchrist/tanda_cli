module TandaCLI
  module Commands
    class Auth
      class Status < Base
        def setup_
          @name = "status"
          @summary = @description = "Show current authentication status"
        end

        def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
          env = config.current

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
          in Configuration::Serialisable::Environment::Production
            display.puts "🌐 #{env.region.display_name} (#{env.region.production_host})"
          in Configuration::Serialisable::Environment::Staging
            display.puts "🌐 #{env.region.display_name} (#{env.region.staging_host})"
          in Configuration::Serialisable::Environment::Custom
            # URL already shown in display_label
          end
        end
      end
    end
  end
end
