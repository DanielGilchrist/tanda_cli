require "../../client_builder"

module TandaCLI
  module Commands
    class ClockIn
      class Finish < Commands::Base
        include ClientBuilder

        def setup_
          @name = "finish"
          @summary = @description = "Clock out"

          ClockIn.add_options(self)
        end

        def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
          parsed_options = ClockIn.parse_options(options)
          Executors::ClockIn.new(client, ClockIn::ClockType::Finish, parsed_options).execute
        end
      end
    end
  end
end
