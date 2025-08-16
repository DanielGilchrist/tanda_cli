require "./period"
require "./calculator"
require "./summary"

module TandaCLI
  module Models
    module TimeWorked
      class WeekPeriod < Period
        def fetch_shifts : Array(Types::Shift)
          to = Utils::Time.now
          start_day = @context.config.start_of_week

          if offset = @offset
            from = (to + offset.weeks).at_beginning_of_week(start_day)
            to = from + 6.days
            @context.display.info("Showing time worked offset #{offset} weeks")
          end

          from ||= to.at_beginning_of_week(start_day)
          fetch_visible_shifts(from, to)
        end

        def calculate_and_display(display_details : Bool = false)
          shifts = fetch_shifts
          organisation = @context.config.current_organisation!
          regular_hours_schedules = organisation.regular_hours_schedules

          treat_paid_breaks_as_unpaid = @context.config.treat_paid_breaks_as_unpaid? || false
          calculator = Calculator.new(@context, treat_paid_breaks_as_unpaid)
          summary = calculator.calculate(shifts, regular_hours_schedules)

          if !summary.has_work_or_leave?
            @context.stdout.puts "You haven't clocked in this week"
            return
          end

          if display_details
            display_shift_details(shifts, calculator, regular_hours_schedules)
          end

          if shifts.any?(&.ongoing?)
            display_time_left_or_overtime(shifts, summary, regular_hours_schedules)
          end

          @context.stdout.puts("You've worked #{summary.total_hours_worked_text} this week")
          return if summary.total_leave_hours.zero?

          @context.stdout.puts("You've taken #{summary.total_leave_hours_text} of leave this week")
        end

        private def display_time_left_or_overtime(shifts : Array(Types::Shift), summary : Summary, regular_hours_schedules : Array(RegularHoursSchedule)?)
          return if regular_hours_schedules.nil? || regular_hours_schedules.empty?

          shifts_by_day_of_week = shifts.group_by(&.day_of_week)

          applicable_regular_hours_schedules = regular_hours_schedules.select do |schedule|
            shifts_by_day_of_week.has_key?(schedule.day_of_week)
          end
          return if applicable_regular_hours_schedules.empty?

          time_left = applicable_regular_hours_schedules.sum do |regular_hours_schedule|
            shifts = shifts_by_day_of_week[regular_hours_schedule.day_of_week]?
            if shifts && shifts.any?(&.ongoing_without_break?)
              regular_hours_schedule.length
            else
              regular_hours_schedule.worked_length
            end
          end - summary.total_time_worked - summary.total_leave_hours

          header_text = time_left.positive? ? "Time left today" : "Overtime this week"
          absolute_time_left = time_left.abs
          @context.stdout.puts "#{"#{header_text}:".colorize.white.bold} #{absolute_time_left.hours} hours and #{absolute_time_left.minutes} minutes"

          clock_out_text = time_left.positive? ? "You can clock out at" : "Overtime since"

          pretty_time = Time::Format.new("%l:%M %p").format(Utils::Time.now + time_left).strip
          @context.stdout.puts "#{clock_out_text}: #{pretty_time}"
          @context.stdout.puts
        end
      end
    end
  end
end
