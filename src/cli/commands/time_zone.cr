module Tanda::CLI
  module CLI::Commands
    class TimeZone
      def initialize(config : Configuration, new_time_zone : String?)
        @config = config
        @new_time_zone = new_time_zone
      end

      def execute
        puts "\n"

        if new_time_zone
          set_time_zone
        else
          display_time_zone
        end
      end

      private getter config : Configuration
      private getter new_time_zone : String?

      private def new_time_zone! : String
        new_time_zone.not_nil!
      end

      private def display_time_zone
        if time_zone = config.time_zone
          puts "The current time zone is #{config.time_zone}"
        else
          puts "A time zone isn't currently set"
          puts "Set it with `tanda_cli time_zone --set <time_zone>`"
        end
      end

      private def set_time_zone
        validate_time_zone!

        new_time_zone = new_time_zone!
        config.time_zone = new_time_zone
        config.save!

        puts "Successfully set current time zone to \"#{new_time_zone}\""
      end

      private def validate_time_zone!
        new_time_zone = new_time_zone!
        Time::Location.load(new_time_zone)
      rescue Time::Location::InvalidLocationNameError
        puts "#{"Error:".colorize(:red)} Invalid time zone \"#{new_time_zone}\""
        exit
      end
    end
  end
end
