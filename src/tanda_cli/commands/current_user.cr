require "./base"

module TandaCLI
  module Commands
    class CurrentUser < Base
      def setup_
        @name = "current_user"
        @summary = @description = "View the current user, list available users or set the current user"

        add_commands(
          CurrentUser::Display,
          CurrentUser::List,
          CurrentUser::Set
        )
      end

      def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
        io.puts help_template
      end
    end
  end
end
