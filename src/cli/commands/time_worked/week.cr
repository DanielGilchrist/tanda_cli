require "./base"

module Tanda::CLI
  module CLI::Commands
    module TimeWorked
      class Week < Base
        def execute
          to = Utils::Time.now
          start_day = Current.config.start_of_week

          if offset = self.offset
            from = (to + offset.weeks).at_beginning_of_week(start_day)
            to = from + 6.days
            Utils::Display.info("Showing time worked offset #{offset} weeks")
          end

          from ||= to.at_beginning_of_week(start_day)
          shifts = client.shifts(from, to, show_notes: display?).or(&.display!)

          total_time_worked, total_leave_hours = calculate_time_worked(shifts)
          if total_time_worked.zero? && total_leave_hours.zero?
            puts "You haven't clocked in this week"
          else
            puts("You've worked #{total_time_worked.total_hours.to_i} hours and #{total_time_worked.minutes} minutes this week")
            if !total_leave_hours.zero?
              puts("You've taken #{total_leave_hours.hours} hours and #{total_leave_hours.minutes} minutes of leave this week")
            end
          end
        end
      end
    end
  end
end
