require "../../utils/url"

module Tanda::CLI
  class CLI::Parser
    class StartOfWeek < ConfigParser
      def parse
        parser.on("display", "Display the start of the week") do
          puts "Start of the week is set to #{config.pretty_start_of_week}"
          exit
        end

        parser.on("--set=DAY", "Set the start of the week") do |day|
          if parse_error = config.set_start_of_week(day)
            Utils::Display.error!(parse_error)
          else
            config.save!
            Utils::Display.success("Start of the week set to #{config.pretty_start_of_week}")
          end

          exit
        end
      end
    end
  end
end
