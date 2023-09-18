require "../../client_builder"

module Tanda::CLI
  module CLI::Commands
    class ClockIn
      class Start < CLI::Commands::Base
        include CLI::ClientBuilder

        def setup_
          @name = "start"
          @summary = @description = "Clock in"
          @inherit_options = true
        end

        def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
          parsed_options = ClockIn.parse_options(options)
          CLI::Executors::ClockIn.new(client, ClockIn::ClockType::Start, parsed_options).execute
        end
      end
    end
  end
end
