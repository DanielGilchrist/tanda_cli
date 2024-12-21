require "colorize"
require "../../configuration/types/organisation"

module TandaCLI
  module Executors
    module TimeWorked
      abstract class Base
        alias RegularHoursScheduleBreak = Configuration::Organisation::RegularHoursSchedule::Break

        def initialize(@context : Context, @display : Bool, @offset : Int32?); end

        abstract def execute

        private getter? display : Bool

        private def fetch_visible_shifts(from : Time, to : Time? = nil) : Array(Types::Shift)
          to ||= from
          @context.client.shifts(@context.current.user.id, from, to, show_notes: display?).or(&.display!).select(&.visible?)
        end

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
            @context.io.puts "#{"Time worked:".colorize.white.bold} #{time_worked.hours} hours and #{time_worked.minutes} minutes"
          elsif worked_so_far
            @context.io.puts "#{"Worked so far:".colorize.white.bold} #{worked_so_far.hours} hours and #{worked_so_far.minutes} minutes"
          end

          Representers::Shift.new(shift).display(@context.io)
        end

        private def print_leave(leave_request : Types::LeaveRequest, breakdown : Types::LeaveRequest::DailyBreakdown)
          length = breakdown.hours

          # Don't bother showing days where there are no hours for leave
          return if length.zero?

          @context.io.puts "#{"Leave taken:".colorize.white.bold} #{length.hours} hours and #{length.minutes} minutes"

          Representers::LeaveRequest::DailyBreakdown.new(breakdown, leave_request).display(@context.io)
        end
      end
    end
  end
end
