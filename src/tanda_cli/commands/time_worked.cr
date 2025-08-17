module TandaCLI
  module Commands
    class TimeWorked < Base
      def setup_
        @name = "time_worked"
        @summary = @description = "See how many hours you've worked"

        add_commands(Today, Week)
      end

      def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
        display.puts help_template
      end
    end
  end
end
