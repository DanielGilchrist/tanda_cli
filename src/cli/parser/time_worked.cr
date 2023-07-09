module Tanda::CLI
  class CLI::Parser
    class TimeWorked < APIParser
      def parse
        display = false
        offset : Int32? = nil

        OptionParser.parse do |time_worked_parser|
          time_worked_parser.on("--display", "Show shift/s") do
            display = true
          end

          time_worked_parser.on("--offset=NUMBER", "Day or week offset") do |offset_num|
            offset = offset_num.to_i?
          end
        end

        @parser.on("today", "Time you've worked today") do
          CLI::Commands::TimeWorked::Today.new(client, display, offset).execute
        end

        @parser.on("week", "Time you've worked this week") do
          CLI::Commands::TimeWorked::Week.new(client, display, offset).execute
        end
      end
    end
  end
end
