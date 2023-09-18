require "../base"

module Tanda::CLI
  module CLI::Commands
    class TimeZone
      class Display < Base
        def setup_
          @name = "display"
          @summary = @description = "Display the current time zone"
        end

        def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
          config = Current.config
          if time_zone = config.time_zone
            puts "The current time zone is #{time_zone}"
          else
            puts "A time zone isn't currently set"
            puts "Set it with `tanda_cli time_zone --set <time_zone>`"
          end
        end
      end
    end
  end
end
