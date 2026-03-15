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
          in Models::LeaveShift
            build_leave_shift(builder, classified_shift)
          in Models::WorkedShift
            build_worked_shift(builder, classified_shift)
          end.tap do |rendered|
            builder.puts if rendered && index != last_index
          end
        end
      end

      private def build_leave_shift(builder : Builder, leave_shift : Models::LeaveShift) : Bool
        length = leave_shift.breakdown.hours
        return false if length.zero?

        builder.puts "#{"Leave taken:".colorize.white.bold} #{length.hours} hours and #{length.minutes} minutes"

        leave_shift.daily_breakdown_representer.build(builder)
        true
      end

      private def build_worked_shift(builder : Builder, worked_shift : Models::WorkedShift) : Bool
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
        true
      end
    end
  end
end
