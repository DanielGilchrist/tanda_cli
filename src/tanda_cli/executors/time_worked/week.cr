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

        private def maybe_print_time_left_or_overtime(
          shifts : Array(Types::Shift),
          worked_so_far : Time::Span,
          leave_taken_so_far : Time::Span = Time::Span.zero
        )
          organisation = Current.config.current_environment.current_organisation!
          regular_hours_schedules = organisation.regular_hours_schedules
          return if regular_hours_schedules.nil? || regular_hours_schedules.empty?

          shifts_by_day_of_week = shifts.group_by(&.day_of_week)

          applicable_regular_hours_schedules = regular_hours_schedules.select do |schedule|
            shifts_by_day_of_week.has_key?(schedule.day_of_week)
          end
          return if applicable_regular_hours_schedules.empty?

          time_left = applicable_regular_hours_schedules.sum(&.worked_length) - worked_so_far - leave_taken_so_far
          header_text = time_left.positive? ? "Time left" : "Overtime"
          time_left = time_left.abs if time_left.negative?
          puts "#{"#{header_text}:".colorize.white.bold} #{time_left.hours} hours and #{time_left.minutes} minutes"
        end
      end
    end
  end
end
