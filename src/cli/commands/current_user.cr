require "./base"

module Tanda::CLI
  module CLI::Commands
    class CurrentUser < Base
      def setup_
        @name = "current_user"
        @summary = @description = "View the current user, list available users or set the current user"

        add_commands(
          CurrentUser::Display.new,
          CurrentUser::List.new,
          CurrentUser::Set.new
        )
      end

      def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
        puts help_template
      end
    end
  end
end
