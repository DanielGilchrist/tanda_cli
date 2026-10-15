require "./regular_hours_schedule"

module TandaCLI
  module Models
    struct LatestStart
      def initialize(
        @overtime : Time::Span,
        @schedule : RegularHoursSchedule,
        @date : Time,
      ) : Nil; end

      private getter overtime : Time::Span

      def at : Time
        Utils::Time.at_date(@date, @schedule.start_time) + overtime
      end

      def day_off? : Bool
        !surplus.negative?
      end

      def surplus : Time::Span
        overtime - @schedule.worked_length
      end

      def passed? : Bool
        !day_off? && at <= Utils::Time.now
      end
    end
  end
end
