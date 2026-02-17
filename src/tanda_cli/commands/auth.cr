require "./base"

module TandaCLI
  module Commands
    class Auth < Base
      def setup_
        @name = "auth"
        @summary = @description = "Manage authentication"

        add_commands(
          Auth::Login,
          Auth::Logout,
          Auth::Status
        )
      end

      def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
        display.puts help_template
      end
    end
  end
end
