require "./**"

module Tanda::CLI
  module CLI::Commands
    class Main < Base
      def self.execute(args = ARGV)
        new.tap(&.add_commands(
          Me.new,
          PersonalDetails.new,
          TimeWorked.new.tap(&.add_commands(
            TimeWorked::Today.new,
            TimeWorked::Week.new
          )),
          RefetchToken.new,
          RefetchUsers.new
        )).execute(args)
      end

      def on_setup
        @name = "tanda_cli"
        @description = "A CLI application for people using Tanda/Workforce.com"
      end

      def run(arguments : Cling::Arguments, options : Cling::Options) : Nil
        puts help_template
      end
    end
  end
end
