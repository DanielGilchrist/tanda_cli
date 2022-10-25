require "./base"

module Tanda::CLI
  module CLI::Commands
    module TimeWorked
      class Today < Base
        def execute
          now = Time.local(location: Current.user.time_zone)
          shifts = client.shifts(now)
          total_time_worked = calculate_time_worked(shifts)

          if total_time_worked.zero?
            puts "You haven't clocked in today"
          else
            puts("You've worked #{total_time_worked.total_hours.to_i} hours and #{total_time_worked.minutes} minutes today")
          end
        end
      end
    end
  end
end
