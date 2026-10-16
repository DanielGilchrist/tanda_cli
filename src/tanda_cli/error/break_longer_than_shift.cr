require "./base"

module TandaCLI
  module Error
    class BreakLongerThanShift < Error::Base
      def initialize(
        day_of_week : Time::DayOfWeek,
        break_length : Time::Span,
        hours : Models::TimeRange,
      ) : Nil
        minutes = break_length.total_minutes.to_i
        super("A #{minutes}min break doesn't fit inside #{day_of_week}'s hours " \
              "(#{hours.pretty})")
      end
    end
  end
end
