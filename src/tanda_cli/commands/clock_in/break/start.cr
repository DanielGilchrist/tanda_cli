require "../../helpers/clock_in"

module TandaCLI
  module Commands
    class ClockIn
      class Break
        class Start < Commands::Base
          include Helpers::ClockIn

          def setup_
            @name = "start"
            @summary = @description = "Start break"

            ClockIn.add_options(self)
          end

          def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
            parsed_options = ClockIn.parse_options(options)
            execute_clock_in(:break_start, parsed_options)
          end
        end
      end
    end
  end
end
