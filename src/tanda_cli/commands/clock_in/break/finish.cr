module TandaCLI
  module Commands
    class ClockIn
      class Break
        class Finish < Commands::Base
          def setup_
            @name = "finish"
            @summary = @description = "Finish break"

            ClockIn.add_options(self)
          end

          def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
            parsed_options = ClockIn.parse_options(options)
            Executors::ClockIn.new(context, ClockIn::ClockType::BreakFinish, parsed_options).execute
          end
        end
      end
    end
  end
end
