module TandaCLI
  module Commands
    class ClockIn
      class Break
        class Start < Commands::Base
          required_scopes :device

          def setup_
            @name = "start"
            @summary = @description = "Start break"

            ClockIn.add_options(self)
          end

          def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
            parsed_options = ClockIn.parse_options(options)
            Executors::ClockIn.new(context, ClockIn::ClockType::BreakStart, parsed_options).execute
          end
        end
      end
    end
  end
end
