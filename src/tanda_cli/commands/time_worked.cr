require "../client_builder"

module TandaCLI
  module Commands
    class TimeWorked < Base
      include ClientBuilder

      def setup_
        @name = "time_worked"
        @summary = @description = "See how many hours you've worked"

        add_commands(Today.new, Week.new)
      end

      def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
        Utils::Display.print help_template
      end
    end
  end
end
