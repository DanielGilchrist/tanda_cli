module TandaCLI
  module Models
    struct RegularHoursWeek
      module Edit
        record Hours, days : DaySet, hours : TimeRange, break_plan : BreakPlan::Any?
      end
    end
  end
end
