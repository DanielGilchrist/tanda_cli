require "./base"

module TandaCLI
  module Executors
    module TimeWorked
      class Week < Base
        def execute
          to = Utils::Time.now
          start_day = @context.config.start_of_week

          if offset = @offset
            from = (to + offset.weeks).at_beginning_of_week(start_day)
            to = from + 6.days
            @context.display.info("Showing time worked offset #{offset} weeks")
          end

          from ||= to.at_beginning_of_week(start_day)
          shifts = fetch_visible_shifts(from, to)

          organisation = @context.config.current_organisation!
          regular_hours_schedules = organisation.regular_hours_schedules
          total_time_worked, total_leave_hours = calculate_time_worked(shifts, regular_hours_schedules)
          if total_time_worked.zero? && total_leave_hours.zero?
            @context.display.puts "You haven't clocked in this week"
          else
            if shifts.any?(&.ongoing?)
              maybe_print_time_left_or_overtime(shifts, total_time_worked, total_leave_hours)
            end

            @context.display.puts("You've worked #{total_time_worked.total_hours.to_i} hours and #{total_time_worked.minutes} minutes this week")
            if !total_leave_hours.zero?
              @context.display.puts("You've taken #{total_leave_hours.hours} hours and #{total_leave_hours.minutes} minutes of leave this week")
            end
          end
        end

        private def breaks_already_taken?(
          regular_hours_schedule : Configuration::Serialisable::Organisation::RegularHoursSchedule,
          shifts : Array(Types::Shift),
        ) : Bool
          expected_break_count =
            if regular_hours_schedule.breaks.present?
              regular_hours_schedule.breaks.size
            elsif (automatic_break_length = regular_hours_schedule.automatic_break_length) && automatic_break_length > 0
              1
            else
              0
            end

          return false if expected_break_count.zero?

          taken_break_count = shifts.sum(&.valid_breaks.size)
          taken_break_count >= expected_break_count
        end

        private def maybe_print_time_left_or_overtime(shifts : Array(Types::Shift), worked_so_far : Time::Span, leave_taken_so_far : Time::Span)
          organisation = @context.config.current_organisation!
          regular_hours_schedules = organisation.regular_hours_schedules
          return if regular_hours_schedules.nil? || regular_hours_schedules.empty?

          shifts_by_day_of_week = shifts.group_by(&.day_of_week)

          applicable_regular_hours_schedules = regular_hours_schedules.select do |schedule|
            shifts_by_day_of_week.has_key?(schedule.day_of_week)
          end
          return if applicable_regular_hours_schedules.empty?

          time_left = applicable_regular_hours_schedules.sum do |regular_hours_schedule|
            shifts = shifts_by_day_of_week[regular_hours_schedule.day_of_week]?
            if shifts && shifts.any?(&.ongoing_without_break?) && !breaks_already_taken?(regular_hours_schedule, shifts)
              regular_hours_schedule.length
            else
              regular_hours_schedule.worked_length
            end
          end - worked_so_far - leave_taken_so_far

          header_text = time_left.positive? ? "Time left today" : "Overtime this week"
          absolute_time_left = time_left.abs
          @context.display.puts "#{"#{header_text}:".colorize.white.bold} #{absolute_time_left.hours} hours and #{absolute_time_left.minutes} minutes"

          clock_out_text = time_left.positive? ? "You can clock out at" : "Overtime since"

          pretty_time = Time::Format.new("%l:%M %p").format(Utils::Time.now + time_left).strip
          @context.display.puts "#{clock_out_text}: #{pretty_time}"
          @context.display.puts
        end
      end
    end
  end
end
