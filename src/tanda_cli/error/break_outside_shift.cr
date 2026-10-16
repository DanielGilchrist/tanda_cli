require "./base"

module TandaCLI
  module Error
    class BreakOutsideShift < Error::Base
      def initialize(
        day_of_week : Time::DayOfWeek,
        break_range : Models::TimeRange,
        hours : Models::TimeRange,
      ) : Nil
        super("Break #{break_range.pretty} is outside #{day_of_week}'s hours (#{hours.pretty})")
      end
    end
  end
end
