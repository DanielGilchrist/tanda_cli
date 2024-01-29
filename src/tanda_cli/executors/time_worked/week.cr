require "./base"

module TandaCLI
  module Executors
    module TimeWorked
      class Week < Base
        def execute
          to = Utils::Time.now
          start_day = Current.config.start_of_week

          if offset = @offset
            from = (to + offset.weeks).at_beginning_of_week(start_day)
            to = from + 6.days
            Utils::Display.info("Showing time worked offset #{offset} weeks")
          end

          from ||= to.at_beginning_of_week(start_day)
          shifts = @client.shifts(from, to, show_notes: display?).or(&.display!)

          total_time_worked, total_leave_hours = calculate_time_worked(shifts)
          if total_time_worked.zero? && total_leave_hours.zero?
            puts "You haven't clocked in this week"
          else
            if shifts.any?(&.ongoing?)
              maybe_print_time_left_or_overtime(shifts, total_time_worked, total_leave_hours)
            end

            puts("You've worked #{total_time_worked.total_hours.to_i} hours and #{total_time_worked.minutes} minutes this week")
            if !total_leave_hours.zero?
              puts("You've taken #{total_leave_hours.hours} hours and #{total_leave_hours.minutes} minutes of leave this week")
            end
          end
        end

        private def maybe_print_time_left_or_overtime(shifts : Array(Types::Shift), worked_so_far : Time::Span, leave_taken_so_far : Time::Span)
          organisation = Current.config.current_organisation!
          regular_hours_schedules = organisation.regular_hours_schedules
          return if regular_hours_schedules.nil? || regular_hours_schedules.empty?

          shifts_by_day_of_week = shifts.group_by(&.day_of_week)

          applicable_regular_hours_schedules = regular_hours_schedules.select do |schedule|
            shifts_by_day_of_week.has_key?(schedule.day_of_week)
          end
          return if applicable_regular_hours_schedules.empty?

          time_left = applicable_regular_hours_schedules.sum do |regular_hours_schedule|
            shifts = shifts_by_day_of_week[regular_hours_schedule.day_of_week]?
            if shifts && shifts.any?(&->ongoing_without_break?(Types::Shift))
              regular_hours_schedule.length
            else
              regular_hours_schedule.worked_length
            end
          end - worked_so_far - leave_taken_so_far

          header_text = time_left.positive? ? "Time left today" : "Overtime this week"
          absolute_time_left = time_left.abs
          puts "#{"#{header_text}:".colorize.white.bold} #{absolute_time_left.hours} hours and #{absolute_time_left.minutes} minutes"

          clock_out_text = time_left.positive? ? "You can clock out at" : "Overtime since"

          pretty_time = Time::Format.new("%l:%M %p").format(Utils::Time.now + time_left).strip
          puts "#{clock_out_text}: #{pretty_time}"
          puts
        end

        private def ongoing_without_break?(shift : Types::Shift) : Bool
          shift.ongoing? && shift.breaks.empty?
        end
      end
    end
  end
end
