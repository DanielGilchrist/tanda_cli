module TandaCLI
  module Commands
    class ClockIn
      class Finish < Commands::Base
        required_scopes :device

        def setup_
          @name = "finish"
          @summary = @description = "Clock out"

          ClockIn.add_options(self)
        end

        def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
          parsed_options = ClockIn.parse_options(options)
          Executors::ClockIn.new(context, ClockIn::ClockType::Finish, parsed_options).execute
        end
      end
    end
  end
end
