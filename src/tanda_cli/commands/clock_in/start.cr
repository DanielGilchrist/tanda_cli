require "../helpers/clock_in"

module TandaCLI
  module Commands
    class ClockIn
      class Start < Commands::Base
        include Helpers::ClockIn

        def setup_
          @name = "start"
          @summary = @description = "Clock in"

          ClockIn.add_options(self)
        end

        def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
          parsed_options = ClockIn.parse_options(options)
          execute_clock_in(:start, parsed_options)
        end
      end
    end
  end
end
