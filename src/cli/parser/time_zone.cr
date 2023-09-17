module Tanda::CLI
  class CLI::Parser
    class TimeZone < ConfigParser
      def parse
        new_time_zone : String? = nil

        OptionParser.parse do |set_time_zone_parser|
          set_time_zone_parser.on("--set=TIME_ZONE", "Set the current time zone") do |time_zone|
            new_time_zone = time_zone
          end
        end

        CLI::Executors::TimeZone.new(config, new_time_zone).execute
        exit
      end
    end
  end
end
