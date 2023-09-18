require "../../client_builder"
require "../../executors/time_worked/today"

module Tanda::CLI
  module CLI::Commands
    class TimeWorked
      class Today < CLI::Commands::Base
        include CLI::ClientBuilder

        def setup_
          @name = "today"
          @summary = @description = "Show time worked for today"

          add_option 'd', "display", description: "Print Shift"
          add_option 'o', "offset", description: "Offset from today"
        end

        def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
          display = options.has?("display")
          offset = options.get?("offset").try(&.as_i32)

          CLI::Executors::TimeWorked::Today.new(client, display, offset).execute
        end
      end
    end
  end
end
