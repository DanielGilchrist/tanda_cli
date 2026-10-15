require "../helpers/time_worked"

module TandaCLI
  module Commands
    struct TimeWorked
      @[Kebab::Command(summary: "Show time worked for a week")]
      struct Week
        include Kebab::Parseable
        include Helpers::TimeWorked

        @[Kebab::Option(short: 'd', description: "Print Shift")]
        getter? display : Bool = false

        @[Kebab::Option(short: 'o', description: "Offset from today")]
        getter offset : Int32?

        def run(context : Context) : Nil
          display = context.display
          offset = self.offset

          to = Utils::Time.now
          start_day = context.config.start_of_week

          if offset
            from = (to + offset.weeks).at_beginning_of_week(start_day)
            to = from + 6.days
            display.info("Showing time worked offset #{offset} weeks")
          end

          from ||= to.at_beginning_of_week(start_day)
          api_shifts = context.client.shifts
            .list(context.current.user.id, from, to, show_notes: display?)
            .or { |error| display.error!(error) }

          leave_requests = leave_requests_for(context, api_shifts)

          organisation = context.config.current_organisation!
          regular_hours_schedules = organisation.regular_hours_schedules
          treat_paid_breaks_as_unpaid = context.config.treat_paid_breaks_as_unpaid?

          summary = Models::ShiftSummary.from_api(api_shifts, leave_requests, treat_paid_breaks_as_unpaid, regular_hours_schedules)

          if summary.empty?
            return display.puts "You haven't clocked in this week"
          end

          if display?
            summary.representer.display(display)
            display.puts
          end

          if summary.any_ongoing?
            maybe_print_time_left_or_overtime(display, summary)
          else
            break_even_start = summary.break_even_start_today if offset.nil?
            maybe_print_overtime_or_undertime(display, summary, break_even_start)
          end

          worked_time = summary.worked_time
          leave_time = summary.leave_time

          display.puts("You've worked #{worked_time.total_hours.to_i} hours and #{worked_time.minutes} minutes this week")

          if !leave_time.zero?
            display.puts("You've taken #{leave_time.hours} hours and #{leave_time.minutes} minutes of leave this week")
          end
        end

        private def maybe_print_time_left_or_overtime(display : TandaCLI::Display, summary : Models::ShiftSummary) : Nil
          time_left = summary.time_left
          return unless time_left

          absolute_time_left = time_left.abs

          header_text = time_left.positive? ? "Time left today" : "Overtime this week"
          display.puts "#{"#{header_text}:".colorize.white.bold} #{absolute_time_left.total_hours.to_i} hours and #{absolute_time_left.minutes} minutes"

          clock_out_text = time_left.positive? ? "Regular hours reached at" : "Overtime since"

          pretty_time = Time::Format.new("%l:%M %p").format(Utils::Time.now + time_left).strip
          display.puts "#{clock_out_text}: #{pretty_time}"
          display.puts
        end

        private def maybe_print_overtime_or_undertime(
          display : TandaCLI::Display,
          summary : Models::ShiftSummary,
          break_even_start : Models::BreakEvenStart?,
        ) : Nil
          time_left = summary.time_left
          return if time_left.nil? || time_left.zero?

          balance = time_left.abs
          header_text = time_left.negative? ? "Overtime this week" : "Undertime this week"
          display.puts "#{"#{header_text}:".colorize.white.bold} #{balance.total_hours.to_i} hours and #{balance.minutes} minutes"

          print_break_even_start(display, break_even_start) if break_even_start && !break_even_start.passed?

          display.puts
        end

        private def print_break_even_start(display : TandaCLI::Display, break_even_start : Models::BreakEvenStart) : Nil
          unless break_even_start.day_off?
            at = break_even_start.at
            wait = at - Utils::Time.now
            return display.puts "Starting at #{Utils::Time.pretty_time(at)} clears it by your usual finish (in #{wait.hours} hours and #{wait.minutes} minutes)"
          end

          surplus = break_even_start.surplus
          return display.puts "Overtime covers today exactly" if surplus.zero?

          display.puts "Overtime covers today with #{surplus.total_hours.to_i} hours and #{surplus.minutes} minutes to spare"
        end
      end
    end
  end
end
