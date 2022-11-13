require "./base"

module Tanda::CLI
  module CLI::Commands
    module TimeWorked
      class Today < Base
        def execute
          now = Utils::Time.now
          shifts = client.shifts(now).or(&.display!)

          total_time_worked, total_leave_hours = calculate_time_worked(shifts)
          if total_time_worked.zero? && total_leave_hours.zero?
            puts "You haven't clocked in today"
          end

          if !total_time_worked.zero?
            puts("You've worked #{total_time_worked.total_hours.to_i} hours and #{total_time_worked.minutes} minutes today")
          end

          if !total_leave_hours.zero?
            puts("You took #{total_leave_hours.hours} hours and #{total_leave_hours.minutes} minutes of leave today")
          end
        end
      end
    end
  end
end
