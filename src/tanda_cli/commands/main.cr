module TandaCLI
  module Commands
    class Main < Base
      def setup_
        @name = "tanda_cli"
        @description = "A CLI application for people using Tanda/Workforce.com"

        add_commands(
          Me.new,
          PersonalDetails.new,
          ClockIn.new,
          TimeWorked.new,
          Balance.new,
          RegularHours.new,
          CurrentUser.new,
          TimeZone.new,
          RefetchToken.new,
          RefetchUsers.new,
          Mode.new,
          StartOfWeek.new
        )
      end

      def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
        puts help_template
      end
    end
  end
end
