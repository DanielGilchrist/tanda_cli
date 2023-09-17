require "cling"
require "../../client_builder"
require "../../executors/time_worked/today"

module Tanda::CLI
  module CLI::Commands
    class TimeWorked
      class Today < Cling::Command
        include CLI::ClientBuilder

        def setup : Nil
          @name = "today"
          @summary = @description = "Show time worked for today"

          add_option 'd', "display", description: "Print Shift"
          add_option 'o', "offset", description: "Offset from today"

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
          display = options.has?("display")
          offset = options.get?("offset").try(&.as_i32)

          CLI::Executors::TimeWorked::Today.new(client, display, offset).execute
        end
      end
    end
  end
end
