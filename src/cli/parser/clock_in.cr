module Tanda::CLI
  class CLI::Parser
    class ClockIn
      enum ClockType
        Start
        Finish
        BreakStart
        BreakFinish

        def to_underscore : String
          to_s.underscore
        end
      end

      def initialize(@parser : OptionParser, @client : API::Client); end

      def parse
        parser.on("status", "Check clockin status") do
          CLI::Commands::ClockIn::Status.new(client).execute
        end

        parser.on("start", "Clock in") do
          execute_clock_in(ClockType::Start)
        end

        parser.on("finish", "Clock out") do
          execute_clock_in(ClockType::Finish)
        end

        parser.on("break", "Clock a break") do
          parser.on("start", "Start break") do
            execute_clock_in(ClockType::BreakStart)
          end

          parser.on("finish", "Finish break") do
            execute_clock_in(ClockType::BreakFinish)
          end
        end
      end

      private getter parser : OptionParser
      private getter client : API::Client

      private def execute_clock_in(type : ClockType)
        CLI::Commands::ClockIn.new(client, type).execute
        exit
      end
    end
  end
end
