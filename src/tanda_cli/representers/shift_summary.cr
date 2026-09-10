require "./base"
require "./shift"
require "./leave_request/daily_breakdown"

module TandaCLI
  module Representers
    struct ShiftSummary < Base(Models::ShiftSummary)
      private def build_display(builder : Builder) : Nil
        displayable_shifts = @object.select { |classified_shift| displayable?(classified_shift) }
        last_index = displayable_shifts.size - 1

        displayable_shifts.each_with_index do |classified_shift, index|
          case classified_shift
          in Models::LeaveShift
            build_leave_shift(builder, classified_shift)
          in Models::WorkedShift
            build_worked_shift(builder, classified_shift)
          end

          builder.puts if index != last_index
        end
      end

      private def displayable?(classified_shift : Models::Shift::Any) : Bool
        case classified_shift
        in Models::LeaveShift
          !classified_shift.leave_taken.zero?
        in Models::WorkedShift
          @object.recorded?(classified_shift)
        end
      end

      private def build_leave_shift(builder : Builder, leave_shift : Models::LeaveShift) : Nil
        length = leave_shift.leave_taken

        builder.puts "#{"Leave taken:".colorize.white.bold} #{length.hours} hours and #{length.minutes} minutes"

        leave_shift.daily_breakdown_representer.build(builder)
      end

      private def build_worked_shift(builder : Builder, worked_shift : Models::WorkedShift) : Nil
        day_name = worked_shift.date.to_s("%A")

        if @object.assumed_start_for?(worked_shift)
          builder.puts "#{"⚠️ Warning:".colorize.yellow.bold} Missing start time for #{day_name}, assuming regular hours start time"
        end

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
      end
    end
  end
end
