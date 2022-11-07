module Tanda::CLI
  class CLI::Parser
    class TimeWorked
      def initialize(@parser : OptionParser, @client : API::Client); end

      def parse
        display = false

        OptionParser.parse do |time_worked_parser|
          time_worked_parser.on("--display", "Show shift/s") do
            display = true
          end
        end

        parser.on("today", "Time you've worked today") do
          CLI::Commands::TimeWorked::Today.new(client, display).execute
        end

        parser.on("week", "Time you've worked this week") do
          CLI::Commands::TimeWorked::Week.new(client, display).execute
        end
      end

      private getter parser : OptionParser
      private getter client : API::Client
    end
  end
end
