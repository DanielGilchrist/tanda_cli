module Tanda::CLI
  class CLI::Parser
    class ClockIn < APIParser
      enum ClockType
        Start
        Finish
        BreakStart
        BreakFinish

        def to_underscore : String
          to_s.underscore
        end
      end

      def parse
        parser.on("status", "Check clockin status") do
          CLI::Commands::ClockIn::Status.new(client).execute
        end

        parser.on("display", "Display current clockins") do
          CLI::Commands::ClockIn::Display.new(client).execute
        end

        skip_validations = false

        OptionParser.parse do |skip_validations_parser|
          skip_validations_parser.on("--skip-validations", "Skip clock in validations") do
            skip_validations = true
          end
        end

        parser.on("start", "Clock in") do
          execute_clock_in(ClockType::Start, skip_validations)
        end

        parser.on("finish", "Clock out") do
          execute_clock_in(ClockType::Finish, skip_validations)
        end

        parser.on("break", "Clock a break") do
          parser.on("start", "Start break") do
            execute_clock_in(ClockType::BreakStart, skip_validations)
          end

          parser.on("finish", "Finish break") do
            execute_clock_in(ClockType::BreakFinish, skip_validations)
          end
        end
      end

      private def execute_clock_in(type : ClockType, skip_validations : Bool = false)
        CLI::Commands::ClockIn.new(client, type, skip_validations).execute
        exit
      end
    end
  end
end
