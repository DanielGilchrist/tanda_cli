require "cling"
require "../client_builder"

module Tanda::CLI
  module CLI::Commands
    class TimeWorked < Cling::Command
      include CLI::ClientBuilder

      def setup : Nil
        @name = "time_worked"
        @summary = @description = "See how many hours you've worked"

        add_option 'h', "help", description: "shows help information"
      end

      def pre_run(arguments : Cling::Arguments, options : Cling::Options) : Bool
        if options.has?("help")
          puts help_template

          false
        else
          true
        end
      end

      def run(arguments : Cling::Arguments, options : Cling::Options) : Nil
        puts help_template
      end
    end
  end
end
