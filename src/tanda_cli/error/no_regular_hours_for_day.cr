require "./base"

module TandaCLI
  module Error
    class NoRegularHoursForDay < Error::Base
      def initialize(day_of_week : Time::DayOfWeek, example : String) : Nil
        super(
          "#{day_of_week} has no regular hours yet",
          "Give it hours too, e.g. \"#{example}\"",
        )
      end
    end
  end
end
