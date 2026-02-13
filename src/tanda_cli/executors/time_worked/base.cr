require "colorize"
require "../../configuration/serialisable/organisation"

module TandaCLI
  module Executors
    module TimeWorked
      abstract class Base
        alias RegularHoursScheduleBreak = Configuration::Serialisable::Organisation::RegularHoursSchedule::Break
        alias RegularHoursSchedule = Configuration::Serialisable::Organisation::RegularHoursSchedule

        def initialize(@context : Context, @display : Bool, @offset : Int32?); end

        abstract def execute

        private getter? display : Bool

        private def fetch_visible_shifts(from : Time, to : Time? = nil) : Array(Types::Shift)
          to ||= from

          @context
            .client
            .shifts(@context.current.user.id, from, to, show_notes: display?)
            .or { |error| @context.display.error!(error) }
            .select(&.visible?)
        end

        private def calculate_time_worked(shifts : Array(Types::Shift), regular_hours_schedules : Array(RegularHoursSchedule)? = nil) : Tuple(Time::Span, Time::Span)
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

            treat_paid_breaks_as_unpaid = @context.config.treat_paid_breaks_as_unpaid? || false
            time_worked = shift.time_worked(treat_paid_breaks_as_unpaid)
            worked_so_far = shift.worked_so_far(treat_paid_breaks_as_unpaid)

            if time_worked.nil? && shift.finish_time.nil? && regular_hours_schedules
              time_worked = calculate_expected_time_worked(shift, treat_paid_breaks_as_unpaid, regular_hours_schedules)
            end

            print_shift(shift, time_worked, worked_so_far, regular_hours_schedules) if display?

            total_time = time_worked || worked_so_far
            total_time_worked += total_time if total_time
          end

          {total_time_worked, total_leave_hours}
        end

        private def print_shift(shift : Types::Shift, time_worked : Time::Span?, worked_so_far : Time::Span?, regular_hours_schedules : Array(RegularHoursSchedule)? = nil)
          if time_worked
            @context.display.puts "#{"Time worked:".colorize.white.bold} #{time_worked.hours} hours and #{time_worked.minutes} minutes"
          elsif worked_so_far
            @context.display.puts "#{"Worked so far:".colorize.white.bold} #{worked_so_far.hours} hours and #{worked_so_far.minutes} minutes"
          end

          expected_finish_time = nil
          expected_break_length = nil
          if shift.finish_time.nil? && regular_hours_schedules
            schedule = regular_hours_schedules.find(&.day_of_week.==(shift.day_of_week))
            if schedule && shift.date.date != Utils::Time.now.date
              expected_finish_time = Utils::Time.pretty_time(schedule.finish_time)
              expected_break_length = schedule.break_length
            end
          end

          Representers::Shift.new(shift, expected_finish_time, expected_break_length).display(@context.display)
          @context.display.puts
        end

        private def print_leave(leave_request : Types::LeaveRequest, breakdown : Types::LeaveRequest::DailyBreakdown)
          length = breakdown.hours

          # Don't bother showing days where there are no hours for leave
          return if length.zero?

          @context.display.puts "#{"Leave taken:".colorize.white.bold} #{length.hours} hours and #{length.minutes} minutes"

          Representers::LeaveRequest::DailyBreakdown.new(breakdown, leave_request).display(@context.display)
          @context.display.puts
        end

        private def calculate_expected_time_worked(shift : Types::Shift, treat_paid_breaks_as_unpaid : Bool, regular_hours_schedules : Array(RegularHoursSchedule)) : Time::Span?
          start_time = shift.start_time
          return unless start_time

          schedule = regular_hours_schedules.find(&.day_of_week.==(shift.day_of_week))
          return unless schedule
          return if shift.date.date == Utils::Time.now.date

          if display?
            @context.display.puts "#{"⚠️ Warning:".colorize.yellow.bold} Missing finish time for #{shift.date.to_s("%A")}, assuming regular hours finish time"
          end

          expected_finish = Time.local(
            shift.date.year,
            shift.date.month,
            shift.date.day,
            schedule.finish_time.hour,
            schedule.finish_time.minute,
            location: Utils::Time.location
          )

          actual_break_time = (treat_paid_breaks_as_unpaid ? shift.valid_breaks : shift.valid_breaks.reject(&.paid?)).sum(&.ongoing_length).minutes
          expected_break_time = actual_break_time == 0.minutes ? schedule.break_length : 0.minutes
          total_break_time = actual_break_time + expected_break_time
          (expected_finish - start_time) - total_break_time
        end
      end
    end
  end
end
