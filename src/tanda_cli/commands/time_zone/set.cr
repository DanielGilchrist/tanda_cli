require "../base"

module TandaCLI
  module Commands
    class TimeZone
      class Set < Base
        def setup_
          @name = "set"
          @summary = @description = "Set the current time zone"

          add_argument "time_zone", description: "The time zone to set", required: true
        end

        def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
          time_zone = arguments.get("time_zone").as_s
          validate_time_zone!(time_zone)

          config = Current.config
          config.time_zone = time_zone
          config.save!

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
end
