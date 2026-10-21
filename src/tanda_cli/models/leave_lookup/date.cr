module TandaCLI
  module Models
    module LeaveLookup
      struct Date
        def initialize(@day : ClockInDay) : Nil; end

        def on(start_of_week : ::Time::DayOfWeek) : ::Time
          @day.on(start_of_week)
        end
      end
    end
  end
end
