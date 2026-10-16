module TandaCLI
  module Models
    struct RegularHoursWeek
      module Edit
        record Copy, days : DaySet, from : Time::DayOfWeek
      end
    end
  end
end
