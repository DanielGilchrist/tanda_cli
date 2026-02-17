module TandaCLI
  module Commands
    class Main < Base
      def setup_
        @name = "tanda_cli"
        @description = "A CLI application for people using Tanda/Workforce.com"

        add_commands(
          Auth,
          Me,
          PersonalDetails,
          ClockIn,
          TimeWorked,
          Balance,
          RegularHours,
          CurrentUser,
          Mode,
          StartOfWeek
        )
      end

      def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
        display.puts help_template
      end
    end
  end
end
