module TandaCLI
  module Models
    module TimeWorked
      class Summary
        getter total_time_worked : Time::Span
        getter total_leave_hours : Time::Span

        def initialize(@total_time_worked : Time::Span, @total_leave_hours : Time::Span)
        end

        def has_work_or_leave?
          !total_time_worked.zero? || !total_leave_hours.zero?
        end

        def total_hours_worked_text
          "#{total_time_worked.total_hours.to_i} hours and #{total_time_worked.minutes} minutes"
        end

        def total_leave_hours_text
          "#{total_leave_hours.hours} hours and #{total_leave_hours.minutes} minutes"
        end
      end
    end
  end
end
