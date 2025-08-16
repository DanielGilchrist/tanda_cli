require "./period"
require "./calculator"
require "./summary"

module TandaCLI
  module Models
    module TimeWorked
      class DayPeriod < Period
        def fetch_shifts : Array(Types::Shift)
          now = Utils::Time.now

          if offset = @offset
            now = now + offset.days
            @context.display.info("Showing time worked offset #{offset} days")
          end

          fetch_visible_shifts(now)
        end

        def calculate_and_display(display_details : Bool = false)
          shifts = fetch_shifts

          treat_paid_breaks_as_unpaid = @context.config.treat_paid_breaks_as_unpaid? || false
          calculator = Calculator.new(@context, treat_paid_breaks_as_unpaid)
          summary = calculator.calculate(shifts)

          if !summary.has_work_or_leave?
            @context.stdout.puts("You haven't clocked in today")
            return
          end

          if display_details
            display_shift_details(shifts, calculator)
          end

          unless summary.total_time_worked.zero?
            @context.stdout.puts("You've worked #{summary.total_hours_worked_text} today")
          end
          return if summary.total_leave_hours.zero?

          @context.stdout.puts("You took #{summary.total_leave_hours_text} of leave today")
        end
      end
    end
  end
end
