require "./base"

module Tanda::CLI
  module CLI::Executors
    module TimeWorked
      class Today < Base
        def execute
          now = Utils::Time.now

          if offset = @offset
            now = now + offset.days
            Utils::Display.info("Showing time worked offset #{offset} days")
          end

          shifts = @client.shifts(date: now, show_notes: display?).or(&.display!)

          total_time_worked, total_leave_hours = calculate_time_worked(shifts)
          if total_time_worked.zero? && total_leave_hours.zero?
            puts "You haven't clocked in today"
          end

          unless total_time_worked.zero?
            puts("You've worked #{total_time_worked.total_hours.to_i} hours and #{total_time_worked.minutes} minutes today")
          end

          return if total_leave_hours.zero?

          puts("You took #{total_leave_hours.hours} hours and #{total_leave_hours.minutes} minutes of leave today")
        end
      end
    end
  end
end
