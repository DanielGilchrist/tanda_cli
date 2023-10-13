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
              print_total_time_left_or_overtime(shifts, total_time_worked, total_leave_hours)
            end

            puts("You've worked #{total_time_worked.total_hours.to_i} hours and #{total_time_worked.minutes} minutes this week")
            if !total_leave_hours.zero?
              puts("You've taken #{total_leave_hours.hours} hours and #{total_leave_hours.minutes} minutes of leave this week")
            end
          end
        end

        private def print_total_time_left_or_overtime(shifts : Array(Types::Shift), total_time_worked : Time::Span, total_leave_hours : Time::Span)
          organisation = Current.config.current_environment.current_organisation!
          regular_hours_schedules = organisation.regular_hours_schedules
          return unless regular_hours_schedules

          shifts_by_day_of_week = shifts.index_by(&.day_of_week)

          applicable_regular_hours_schedules = regular_hours_schedules.select do |schedule|
            shifts_by_day_of_week.has_key?(schedule.day_of_week)
          end

          scheduled_time = applicable_regular_hours_schedules.sum do |schedule|
            schedule.length - schedule.break_length
          end

          time_left = (scheduled_time - total_time_worked - total_leave_hours).abs

          header_text = time_left.positive? ? "Time left" : "Overtime"
          puts "#{"#{header_text}:".colorize.white.bold} #{time_left.hours} hours and #{time_left.minutes} minutes"
        end
      end
    end
  end
end
