require "./base"

module TandaCLI
  module Executors
    module TimeWorked
      class Today < Base
        def execute
          now = Utils::Time.now

          if offset = @offset
            now = now + offset.days
            @context.display.info("Showing time worked offset #{offset} days")
          end

          shifts = fetch_visible_shifts(now)

          total_time_worked, total_leave_hours = calculate_time_worked(shifts)
          if total_time_worked.zero? && total_leave_hours.zero?
            @context.stdout.puts "You haven't clocked in today"
          end

          unless total_time_worked.zero?
            @context.stdout.puts("You've worked #{total_time_worked.total_hours.to_i} hours and #{total_time_worked.minutes} minutes today")
          end

          return if total_leave_hours.zero?

          @context.stdout.puts("You took #{total_leave_hours.hours} hours and #{total_leave_hours.minutes} minutes of leave today")
        end
      end
    end
  end
end
