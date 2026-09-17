require "../error/future_clock_in"
require "../error/out_of_order_clock_in"
require "./time_of_day"

module TandaCLI
  module Models
    struct ClockInMoment
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

      private def initialize(@time : ::Time) : Nil; end

      getter time : ::Time
    end
  end
end
