module Tanda::CLI
  module CLI::Commands
    class TimeZone
      def initialize(config : Configuration, new_time_zone : String?)
        @config = config
        @new_time_zone = new_time_zone
      end

      def execute
        puts "\n"

        if time_zone = @new_time_zone
          set_time_zone!(time_zone)
        else
          display_time_zone
        end
      end

      private def display_time_zone
        if time_zone = @config.time_zone
          puts "The current time zone is #{time_zone}"
        else
          puts "A time zone isn't currently set"
          puts "Set it with `tanda_cli time_zone --set <time_zone>`"
        end
      end

      private def set_time_zone!(time_zone : String)
        validate_time_zone!(time_zone)

        @config.time_zone = time_zone
        @config.save!

        Utils::Display.success("Set current time zone to", time_zone)
      end

      private def validate_time_zone!(time_zone : String)
        Time::Location.load(time_zone)
      rescue Time::Location::InvalidLocationNameError
        Utils::Display.error!("Invalid time zone", time_zone)
      end
    end
  end
end
