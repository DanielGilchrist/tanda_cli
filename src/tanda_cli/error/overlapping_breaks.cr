require "./base"

module TandaCLI
  module Error
    class OverlappingBreaks < Error::Base
      def initialize(
        day_of_week : Time::DayOfWeek,
        first : Models::TimeRange,
        second : Models::TimeRange,
      ) : Nil
        super("Breaks #{first.pretty} and #{second.pretty} overlap on #{day_of_week}")
      end
    end
  end
end
