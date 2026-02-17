require "../../helpers/clock_in"

module TandaCLI
  module Commands
    class ClockIn
      class Break
        class Finish < Commands::Base
          include Helpers::ClockIn
          requires_auth!

          def setup_
            @name = "finish"
            @summary = @description = "Finish break"

            ClockIn.add_options(self)
          end

          def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
            parsed_options = ClockIn.parse_options(options)
            execute_clock_in(:break_finish, parsed_options)
          end
        end
      end
    end
  end
end
