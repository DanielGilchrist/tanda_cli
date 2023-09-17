require "../../client_builder"
require "../../executors/time_worked/week"

module Tanda::CLI
  module CLI::Commands
    class TimeWorked
      class Week < CLI::Commands::Base
        include CLI::ClientBuilder

        def on_setup
          @name = "week"
          @summary = @description = "Show time worked for a week"

          add_option 'd', "display", description: "Print Shift"
          add_option 'o', "offset", description: "Offset from today"
        end

        def run(arguments : Cling::Arguments, options : Cling::Options) : Nil
          display = options.has?("display")
          offset = options.get?("offset").try(&.as_i32)

          CLI::Executors::TimeWorked::Week.new(client, display, offset).execute
        end
      end
    end
  end
end
