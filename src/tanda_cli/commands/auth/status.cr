module TandaCLI
  module Commands
    class Auth
      class Status < Base
        def setup_
          @name = "status"
          @summary = @description = "Show current authentication status"
        end

        def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
          mode = config.mode

          unless context.authenticated?
            display.puts "🔒 #{"Not authenticated (#{mode.display_label})".colorize.yellow}"
            display.puts "Run `tanda_cli auth login` to authenticate"
            return
          end

          access_token = config.access_token
          organisation = config.current_organisation?

          display.puts "🔓 #{"Authenticated (#{mode.display_label})".colorize.green}"
          display.puts "📧 #{access_token.email}" if access_token
          display.puts "🏢 #{organisation.name} (user #{organisation.user_id})" if organisation

          case mode
          in Configuration::Mode::Production
            display.puts "🌐 #{config.region.display_name} (#{config.region.production_host})"
          in Configuration::Mode::Staging
            display.puts "🌐 #{config.region.display_name} (#{config.region.staging_host})"
          in Configuration::Mode::Custom
            # location already shown in display_label
          end
        end
      end
    end
  end
end
