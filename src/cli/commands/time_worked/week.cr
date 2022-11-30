require "./base"

module Tanda::CLI
  module CLI::Commands
    module TimeWorked
      class Week < Base
        def execute
          now = Utils::Time.now
          shifts = client.shifts(now.at_beginning_of_week, now.at_end_of_week).or(&.display!)

          total_time_worked, total_leave_hours = calculate_time_worked(shifts)
          if total_time_worked.zero?
            puts "You haven't clocked in this week"
          else
            puts("You've worked #{total_time_worked.total_hours.to_i} hours and #{total_time_worked.minutes} minutes this week")
            if !total_leave_hours.zero?
              puts("You took #{total_leave_hours.hours} hours and #{total_leave_hours.minutes} minutes of leave this week")
            end
          end
        end
      end
    end
  end
end
