module TandaCLI
  module Models
    struct RegularHoursWeek
      module Edit
        record Break, days : DaySet, break_plan : BreakPlan::Any
      end
    end
  end
end
