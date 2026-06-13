require "../error/future_clock_in"
require "../error/out_of_order_clock_in"
require "../error/unparsable_date"
require "./time_of_day"

module TandaCLI
  module Models
    struct ClockInMoment
      def self.parse(at : String, date : String?) : ClockInMoment | Error::Base
        day =
          case parsed_day = parse_day(date || "today")
          in ::Time
            parsed_day
          in Error::Base
            return parsed_day
          end

        parse(at, on: day)
      end

      def self.parse(input : String, on day : ::Time, after previous : ::Time? = nil) : ClockInMoment | Error::Base
        time_of_day =
          case parsed = TimeOfDay.parse(input)
          in TimeOfDay
            parsed
          in Error::Base
            return parsed
          end

        from(time_of_day, on: day, after: previous)
      end

      def self.from(time_of_day : TimeOfDay, on day : ::Time, after previous : ::Time? = nil) : ClockInMoment | Error::Base
        time = time_of_day.on(day)
        return Error::FutureClockIn.new(time) if time > Utils::Time.now
        return Error::OutOfOrderClockIn.new(time, previous) if previous && time <= previous

        new(time)
      end

      def self.parse_day(input : String) : ::Time | Error::Base
        case input.downcase
        when "today"
          Utils::Time.now
        when "yesterday"
          Utils::Time.now - 1.day
        else
          begin
            Utils::Time.iso_date(input)
          rescue ::Time::Format::Error
            Error::UnparsableDate.new(input)
          end
        end
      end

      private def initialize(@time : ::Time); end

      getter time : ::Time
    end
  end
end
