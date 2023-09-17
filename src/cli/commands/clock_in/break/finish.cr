require "../../../client_builder"

module Tanda::CLI
  module CLI::Commands
    class ClockIn
      class Break
        class Finish < CLI::Commands::Base
          include CLI::ClientBuilder

          def on_setup
            @name = "finish"
            @summary = @description = "Finish break"
            @inherit_options = true
          end

          def run(arguments : Cling::Arguments, options : Cling::Options) : Nil
            parsed_options = ClockIn.parse_options(options)
            CLI::Executors::ClockIn.new(client, ClockIn::ClockType::BreakFinish, parsed_options).execute
          end
        end
      end
    end
  end
end
