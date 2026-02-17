require "./base"
require "./shift"
require "./leave_request/daily_breakdown"

module TandaCLI
  module Representers
    struct ShiftSummary < Base(Models::ShiftSummary)
      private def build_display(builder : Builder)
        last_index = @object.size - 1

        @object.each_with_index do |classified_shift, index|
          case classified_shift
          when Models::ShiftSummary::LeaveShift
            build_leave_shift(builder, classified_shift)
          when Models::ShiftSummary::WorkedShift
            build_worked_shift(builder, classified_shift)
          end

          builder.puts if index != last_index
        end
      end

      private def build_leave_shift(builder : Builder, leave_shift : Models::ShiftSummary::LeaveShift)
        length = leave_shift.breakdown.hours
        return if length.zero?

        builder.puts "#{"Leave taken:".colorize.white.bold} #{length.hours} hours and #{length.minutes} minutes"

        LeaveRequest::DailyBreakdown.new(leave_shift.breakdown, leave_shift.leave_request).build(builder)
      end

      private def build_worked_shift(builder : Builder, worked_shift : Models::ShiftSummary::WorkedShift)
        if worked_shift.assumed_finish?
          day_name = worked_shift.date.to_s("%A")
          builder.puts "#{"⚠️ Warning:".colorize.yellow.bold} Missing finish time for #{day_name}, assuming regular hours finish time"
        end

        time_worked = worked_shift.time_worked

        if time_worked
          label = worked_shift.ongoing? ? "Worked so far:" : "Time worked:"
          builder.puts "#{"#{label}".colorize.white.bold} #{time_worked.hours} hours and #{time_worked.minutes} minutes"
        end

        worked_shift.shift_representer.build(builder)
      end
    end
  end
end
