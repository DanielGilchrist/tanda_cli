require "../base"

module TandaCLI
  module Commands
    class TimeZone
      class Display < Base
        def setup_
          @name = "display"
          @summary = @description = "Display the current time zone"
        end

        def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
          config = Current.config
          if time_zone = config.time_zone
            Utils::Display.print "The current time zone is #{time_zone}"
          else
            Utils::Display.print "A time zone isn't currently set"
            Utils::Display.print "Set it with `tanda_cli time_zone --set <time_zone>`"
          end
        end
      end
    end
  end
end
