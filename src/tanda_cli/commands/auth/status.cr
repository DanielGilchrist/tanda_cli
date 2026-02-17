module TandaCLI
  module Commands
    class Auth
      class Status < Base
        def setup_
          @name = "status"
          @summary = @description = "Show current authentication status"
        end

        def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
          environment = config.staging? ? "staging" : "production"

          unless context.authenticated?
            display.puts "🔒 #{"Not authenticated (#{environment})".colorize.yellow}"
            display.puts "Run `tanda_cli auth login` to authenticate"
            return
          end

          email = config.access_token.email
          organisation = config.current_organisation?

          display.puts "🔓 #{"Authenticated (#{environment})".colorize.green}"
          display.puts "📧 #{email}" if email
          display.puts "🏢 #{organisation.name} (user #{organisation.user_id})" if organisation
          display.puts "🌐 #{config.region.display_name} (#{config.host})"
        end
      end
    end
  end
end
