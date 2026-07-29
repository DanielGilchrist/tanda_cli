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
        day_name = worked_shift.date.to_s("%A")

        if @object.assumed_finish_for?(worked_shift)
          builder.puts "#{"⚠️ Warning:".colorize.yellow.bold} Missing finish time for #{day_name}, assuming regular hours finish time"
        end

        breaks = @object.breaks_for(worked_shift)

        if breaks.any_never_finished?
          assumed_length = breaks.assumed_length
          assumption =
            if assumed_length
              "assuming a #{assumed_length.total_minutes.to_i} minute break"
            else
              "break not counted"
            end

          builder.puts "#{"⚠️ Warning:".colorize.yellow.bold} Missing break finish time for #{day_name}, #{assumption}"
        end

        time_worked = @object.time_worked_for(worked_shift)
        label = @object.in_progress?(worked_shift) ? "Worked so far:" : "Time worked:"
        builder.puts "#{label.colorize.white.bold} #{time_worked.hours} hours and #{time_worked.minutes} minutes"

        @object.shift_representer_for(worked_shift).build(builder)
        true
      end
    end
  end
end
