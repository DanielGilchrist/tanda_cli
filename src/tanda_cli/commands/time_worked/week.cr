module TandaCLI
  module Commands
    class TimeWorked
      class Week < Commands::Base
        requires_auth!

        def setup_
          @name = "week"
          @summary = @description = "Show time worked for a week"

          add_option 'd', "display", description: "Print Shift"
          add_option 'o', "offset", type: :single, required: false, description: "Offset from today"
        end

        def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
          display = options.has?("display")
          offset = options.get?("offset").try(&.as_s.to_i32?)

          execute(display, offset)
        end

        private def execute(print_shifts : Bool, offset : Int32?)
          to = Utils::Time.now
          start_day = config.start_of_week

          if offset
            from = (to + offset.weeks).at_beginning_of_week(start_day)
            to = from + 6.days
            display.info("Showing time worked offset #{offset} weeks")
          end

          from ||= to.at_beginning_of_week(start_day)
          shifts = client
            .shifts(current.user.id, from, to, show_notes: print_shifts)
            .or { |error| display.error!(error) }
            .select(&.visible?)

          organisation = config.current_organisation!
          regular_hours_schedules = organisation.regular_hours_schedules
          treat_paid_breaks_as_unpaid = config.treat_paid_breaks_as_unpaid? || false

          summary = Models::ShiftSummary.new(shifts, treat_paid_breaks_as_unpaid, regular_hours_schedules)

          if summary.empty?
            return display.puts "You haven't clocked in this week"
          end

          if print_shifts
            summary.representer.display(display)
            display.puts
          end

          if summary.any_ongoing?
            maybe_print_time_left_or_overtime(summary)
          end

          worked_time = summary.worked_time
          leave_time = summary.leave_time

          display.puts "⏱️  #{"Worked:".colorize.white.bold} #{worked_time.total_hours.to_i} hours and #{worked_time.minutes} minutes"

          if !leave_time.zero?
            display.puts "🌴 #{"Leave:".colorize.white.bold} #{leave_time.hours} hours and #{leave_time.minutes} minutes"
          end
        end

        private def maybe_print_time_left_or_overtime(summary : Models::ShiftSummary)
          time_left = summary.time_left
          return unless time_left

          absolute_time_left = time_left.abs

          if time_left.positive?
            display.puts "⏳ #{"Time left:".colorize.white.bold} #{absolute_time_left.hours} hours and #{absolute_time_left.minutes} minutes"
            pretty_time = Time::Format.new("%l:%M %p").format(Utils::Time.now + time_left).strip
            display.puts "🏁 #{"Clock out at:".colorize.white.bold} #{pretty_time}"
          else
            display.puts "🔥 #{"Overtime:".colorize.yellow.bold} #{absolute_time_left.hours} hours and #{absolute_time_left.minutes} minutes"
            pretty_time = Time::Format.new("%l:%M %p").format(Utils::Time.now + time_left).strip
            display.puts "⏰ #{"Since:".colorize.white.bold} #{pretty_time}"
          end
          display.puts
        end
      end
    end
  end
end
