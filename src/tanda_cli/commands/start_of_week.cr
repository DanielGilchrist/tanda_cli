require "./base"

module TandaCLI
  module Commands
    class StartOfWeek < Base
      def setup_
        @name = "start_of_week"
        @summary = @description = "Set the start of the week (e.g. monday/sunday)"

        add_commands(StartOfWeek::Display.new, StartOfWeek::Set.new)
      end

      def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
        Utils::Display.print help_template
      end
    end
  end
end
