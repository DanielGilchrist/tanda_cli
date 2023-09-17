require "cling"
require "./**"

module Tanda::CLI
  module CLI::Commands
    class Main < Cling::Command
      def self.execute(args = ARGV)
        cli = new
        cli.add_commands(
          Me.new,
          PersonalDetails.new,
          RefetchToken.new
        )

        cli.execute(args)
      end

      def setup : Nil
        @name = "tanda_cli"
        @description = "A CLI application for people using Tanda/Workforce.com"

        add_option 'h', "help", description: "shows help information"
      end

      def pre_run(arguments : Cling::Arguments, options : Cling::Options) : Bool
        if options.has? "help"
          puts help_template

          false
        else
          true
        end
      end

      def run(arguments : Cling::Arguments, options : Cling::Options) : Nil; end
    end
  end
end
