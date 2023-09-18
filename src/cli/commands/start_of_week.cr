require "./base"

module Tanda::CLI
  module CLI::Commands
    class StartOfWeek < Base
      def on_setup
        @name = "start_of_week"
        @summary = @description = "Set the start of the week (e.g. monday/sunday)"

        add_commands(StartOfWeek::Display.new, StartOfWeek::Set.new)
      end

      def run(arguments : Cling::Arguments, options : Cling::Options) : Nil
        puts help_template
      end
    end
  end
end
