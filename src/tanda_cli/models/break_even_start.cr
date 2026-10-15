require "./regular_hours_schedule"

module TandaCLI
  module Models
    struct BreakEvenStart
      def initialize(
        @time_left : Time::Span,
        @schedule : RegularHoursSchedule,
        @date : Time,
      ) : Nil; end

      def at : Time
        Utils::Time.at_date(@date, @schedule.start_time) - @time_left
      end

      def day_off? : Bool
        !surplus.negative?
      end

      def surplus : Time::Span
        -@time_left - @schedule.worked_length
      end

      def passed? : Bool
        !day_off? && at <= Utils::Time.now
      end
    end
  end
end
