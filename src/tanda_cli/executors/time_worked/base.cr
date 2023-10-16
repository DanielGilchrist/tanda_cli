require "colorize"
require "../../configuration/types/organisation"

module TandaCLI
  module Executors
    module TimeWorked
      abstract class Base
        alias RegularHoursScheduleBreak = Configuration::Organisation::RegularHoursSchedule::Break

        def initialize(@client : API::Client, @display : Bool, @offset : Int32?); end

        abstract def execute

        private getter? display : Bool

        private def calculate_time_worked(shifts : Array(Types::Shift)) : Tuple(Time::Span, Time::Span)
          total_time_worked = Time::Span.zero
          total_leave_hours = Time::Span.zero

          shifts.each do |shift|
            leave_request = shift.leave_request
            breakdown = leave_request.breakdown_for(shift) if leave_request

            if leave_request && breakdown
              hours = breakdown.hours
              total_leave_hours += hours if hours
              print_leave(leave_request, breakdown) if display?
              next
            end

            time_worked = shift.time_worked
            worked_so_far = shift.worked_so_far

            print_shift(shift, time_worked, worked_so_far) if display?

            total_time = time_worked || worked_so_far
            total_time_worked += total_time if total_time
          end

          {total_time_worked, total_leave_hours}
        end

        private def print_shift(shift : Types::Shift, time_worked : Time::Span?, worked_so_far : Time::Span?)
          if time_worked
            puts "#{"Time worked:".colorize.white.bold} #{time_worked.hours} hours and #{time_worked.minutes} minutes"
          elsif worked_so_far
            puts "#{"Worked so far:".colorize.white.bold} #{worked_so_far.hours} hours and #{worked_so_far.minutes} minutes"
            case self
            in TimeWorked::Today
              maybe_print_time_left_or_overtime(shift, worked_so_far)
            in TimeWorked::Week
              # no-op
            end
          end

          Representers::Shift.new(shift).display
        end

        private def maybe_print_time_left_or_overtime(
          shifts : Types::Shift | Array(Types::Shift),
          worked_so_far : Time::Span,
          leave_taken_so_far : Time::Span = Time::Span.zero
        )
          organisation = Current.config.current_environment.current_organisation!
          regular_hours_schedules = organisation.regular_hours_schedules
          return if regular_hours_schedules.nil? || regular_hours_schedules.empty?

          shifts_by_day_of_week = begin
            case shifts
            in Types::Shift
              {shifts.day_of_week => shifts}
            in Array(Types::Shift)
              shifts.index_by(&.day_of_week)
            end
          end

          applicable_regular_hours_schedules = regular_hours_schedules.select do |schedule|
            shifts_by_day_of_week.has_key?(schedule.day_of_week)
          end
          return if applicable_regular_hours_schedules.empty?

          time_left = applicable_regular_hours_schedules.sum do |regular_hours_schedule|
            break_length = begin
              if regular_hours_schedule.breaks.any? { |regular_hours_break| break_past_current_time?(regular_hours_break) }
                regular_hours_schedule.break_length
              else
                0.minutes
              end
            end

            regular_hours_schedule.length - break_length
          end - worked_so_far - leave_taken_so_far

          header_text = time_left.positive? ? "Time left" : "Overtime"
          time_left = time_left.abs if time_left.negative?
          puts "#{"#{header_text}:".colorize.white.bold} #{time_left.hours} hours and #{time_left.minutes} minutes"
        end

        private def break_past_current_time?(regular_hours_break : RegularHoursScheduleBreak) : Bool
          Utils::Time.now >= regular_hours_break.finish_time
        end

        private def print_leave(leave_request : Types::LeaveRequest, breakdown : Types::LeaveRequest::DailyBreakdown)
          length = breakdown.hours

          # Don't bother showing days where there are no hours for leave
          return if length.zero?

          puts "#{"Leave taken:".colorize.white.bold} #{length.hours} hours and #{length.minutes} minutes"

          Representers::LeaveRequest::DailyBreakdown.new(breakdown, leave_request).display
        end
      end
    end
  end
end
