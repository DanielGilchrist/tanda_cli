require "../../configuration/serialisable/organisation"

module TandaCLI
  module Models
    module TimeWorked
      class Calculator
        alias RegularHoursScheduleBreak = Configuration::Serialisable::Organisation::RegularHoursSchedule::Break
        alias RegularHoursSchedule = Configuration::Serialisable::Organisation::RegularHoursSchedule

        def initialize(@context : Context, @treat_paid_breaks_as_unpaid : Bool = false)
        end

        def calculate(shifts : Array(Types::Shift), regular_hours_schedules : Array(RegularHoursSchedule)? = nil) : Summary
          total_time_worked = Time::Span.zero
          total_leave_hours = Time::Span.zero

          shifts.each do |shift|
            leave_request = shift.leave_request
            breakdown = leave_request.breakdown_for(shift) if leave_request

            if leave_request && breakdown
              hours = breakdown.hours
              total_leave_hours += hours if hours
              next
            end

            time_worked = shift.time_worked(@treat_paid_breaks_as_unpaid)
            worked_so_far = shift.worked_so_far(@treat_paid_breaks_as_unpaid)

            if time_worked.nil? && shift.finish_time.nil? && regular_hours_schedules
              time_worked = calculate_expected_time_worked(shift, regular_hours_schedules)
            end

            total_time = time_worked || worked_so_far
            total_time_worked += total_time if total_time
          end

          Summary.new(total_time_worked, total_leave_hours)
        end

        def calculate_expected_time_worked(shift : Types::Shift, regular_hours_schedules : Array(RegularHoursSchedule)) : Time::Span?
          start_time = shift.start_time
          return unless start_time

          schedule = regular_hours_schedules.find(&.day_of_week.==(shift.day_of_week))
          return unless schedule
          return if shift.date.date == Utils::Time.now.date

          expected_finish = Time.local(
            shift.date.year,
            shift.date.month,
            shift.date.day,
            schedule.finish_time.hour,
            schedule.finish_time.minute,
            location: Utils::Time.location
          )

          expected_break_time = schedule.break_length
          total_break_time = expected_break_time
          (expected_finish - start_time) - total_break_time
        end

        def warn_missing_finish_time(shift : Types::Shift)
          @context.stdout.puts "#{"⚠️ Warning:".colorize.yellow.bold} Missing finish time for #{shift.date.to_s("%A")}, assuming regular hours finish time"
        end
      end
    end
  end
end
