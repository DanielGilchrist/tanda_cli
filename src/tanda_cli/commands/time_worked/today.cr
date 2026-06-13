require "../helpers/time_worked"

module TandaCLI
  module Commands
    struct TimeWorked
      @[Kebab::Command(summary: "Show time worked for today")]
      struct Today
        include Kebab::Parseable
        include Helpers::TimeWorked

        @[Kebab::Option(short: 'd', description: "Print Shift")]
        getter? display : Bool = false

        @[Kebab::Option(short: 'o', description: "Offset from today")]
        getter offset : Int32?

        def run(context : Context) : Nil
          display = context.display
          print_shifts = self.display?
          offset = self.offset
          now = Utils::Time.now

          if offset
            now = now + offset.days
            display.info("Showing time worked offset #{offset} days")
          end

          api_shifts = context.client.shifts
            .list(context.current.user.id, now, now, show_notes: print_shifts)
            .or { |error| display.error!(error) }

          leave_requests = leave_requests_for(context, api_shifts)
          treat_paid_breaks_as_unpaid = context.config.treat_paid_breaks_as_unpaid?

          summary = Models::ShiftSummary.from_api(api_shifts, leave_requests, treat_paid_breaks_as_unpaid)

          if summary.empty?
            return display.puts "You haven't clocked in today"
          end

          if print_shifts
            summary.representer.display(display)
            display.puts
          end

          worked_time = summary.worked_time
          leave_time = summary.leave_time

          unless worked_time.zero?
            display.puts("You've worked #{worked_time.total_hours.to_i} hours and #{worked_time.minutes} minutes today")
          end

          return if leave_time.zero?

          display.puts("You took #{leave_time.hours} hours and #{leave_time.minutes} minutes of leave today")
        end
      end
    end
  end
end
