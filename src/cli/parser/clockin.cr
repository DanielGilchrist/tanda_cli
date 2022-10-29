module Tanda::CLI
  class CLI::Parser
    class Clockin
      def initialize(@parser : OptionParser, @client : API::Client); end

      def parse
        parser.on("start", "Clock in") do
          execute("start")
        end

        parser.on("finish", "Clock out") do
          execute("finish")
        end

        parser.on("break", "Clock a break") do
          parser.on("start", "Start break") do
            execute("break_start")
          end

          parser.on("finish", "Finish break") do
            execute("break_finish")
          end
        end
      end

      private getter parser : OptionParser
      private getter client : API::Client

      private def execute(type : String)
        CLI::Commands::ClockIn.new(client, type).execute
        exit
      end
    end
  end
end
