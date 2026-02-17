module TandaCLI
  module Commands
    class TimeWorked
      class Today < Commands::Base
        def setup_
          @name = "today"
          @summary = @description = "Show time worked for today"

          add_option 'd', "display", description: "Print Shift"
          add_option 'o', "offset", type: :single, required: false, description: "Offset from today"
        end

        def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
          display = options.has?("display")
          offset = options.get?("offset").try(&.as_s.to_i32?)

          execute(display, offset)
        end

        private def execute(print_shifts : Bool, offset : Int32?)
          now = Utils::Time.now

          if offset
            now = now + offset.days
            display.info("Showing time worked offset #{offset} days")
          end

          shifts = client
            .shifts(current.user.id, now, now, show_notes: print_shifts)
            .or { |error| display.error!(error) }
            .select(&.visible?)

          treat_paid_breaks_as_unpaid = config.treat_paid_breaks_as_unpaid? || false

          summary = Models::ShiftSummary.new(shifts, treat_paid_breaks_as_unpaid)

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
