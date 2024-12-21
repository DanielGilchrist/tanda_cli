module TandaCLI
  module Commands
    class TimeWorked < Base
      def setup_
        @name = "time_worked"
        @summary = @description = "See how many hours you've worked"

        add_commands(Today, Week)
      end

      def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
        puts help_template
      end
    end
  end
end
