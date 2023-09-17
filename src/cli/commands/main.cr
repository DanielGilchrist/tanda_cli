require "./**"

module Tanda::CLI
  module CLI::Commands
    class Main < Base
      def on_setup
        @name = "tanda_cli"
        @description = "A CLI application for people using Tanda/Workforce.com"

        add_commands(
          Me.new,
          PersonalDetails.new,
          TimeWorked.new,
          ClockIn.new,
          RefetchToken.new,
          RefetchUsers.new
        )
      end

      def run(arguments : Cling::Arguments, options : Cling::Options) : Nil
        puts help_template
      end
    end
  end
end
