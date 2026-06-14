require "../../models/clock_in_backfill"

module TandaCLI
  module Commands
    struct ClockIn
      @[Kebab::Command(summary: "Backfill missed clock ins for a day")]
      struct Backfill
        include Kebab::Parseable

        @[Kebab::Option(short: 'd', description: "Day to backfill, defaults to today (\"yesterday\" or YYYY-MM-DD)")]
        getter date : String?

        def run(context : Context) : Nil
          display = context.display

          day = parse_day(context)
          api_shifts = context.client.shifts.list(context.current.user.id, day).or { |error| display.error!(error) }
          shifts = api_shifts.compact_map { |api_shift| Models::WorkedShift.from?(api_shift) }
          backfill = Models::ClockInBackfill.new(day, shifts)

          display.puts "📅 #{Utils::Time.pretty_date(day).colorize.white.bold}"

          return display.puts "Nothing to backfill — this day is already complete." if backfill.complete?

          announce_existing_state(context, backfill)
          interview(context, backfill)

          entries = backfill.entries
          return display.puts "Nothing to backfill." if entries.empty?

          display.puts
          summarise(context, entries)
          return display.puts "Cancelled — nothing submitted." unless confirm?(context)

          submit(context, entries)

          clock_in_word = entries.one? ? "clock in" : "clock ins"
          display.success("Backfilled #{entries.size} #{clock_in_word} for #{Utils::Time.pretty_date(day)}")
        end

        private def parse_day(context : Context) : ::Time
          date_string = date
          return Utils::Time.now if date_string.nil?

          day =
            case parsed = Models::ClockInMoment.parse_day(date_string)
            in ::Time
              parsed
            in Error::Base
              context.display.error!(parsed)
            end

          context.display.error!("You can't backfill a future date") if day.date > Utils::Time.now.date

          day
        end

        private def announce_existing_state(context : Context, backfill : Models::ClockInBackfill) : Nil
          display = context.display

          shift = backfill.ongoing_shift
          return display.puts "No clock ins recorded." if shift.nil?

          display.puts "You clocked in at #{shift.pretty_start_time}."

          if backfill.on_break?
            ongoing_break = shift.breaks.find(&.ongoing?)
            display.puts "Your break started at #{ongoing_break.pretty_start_time}." if ongoing_break
          end
        end

        private def interview(context : Context, backfill : Models::ClockInBackfill) : Nil
          prompt(context, backfill, :start, "🕐 What time did you start?", required: true) if backfill.needs_start?

          if backfill.on_break?
            prompt(context, backfill, :break_finish, "☕ What time did your break finish? (blank to leave it open)")
          end

          while backfill.can_break?
            break unless prompt(context, backfill, :break_start, "☕ Did you take a break? Start time (blank to skip)")

            prompt(context, backfill, :break_finish, "☕ What time did the break finish?", required: true)
          end

          if backfill.can_finish?
            prompt(context, backfill, :finish, "🕐 What time did you finish? (blank if you're still working)")
          end
        end

        private def prompt(
          context : Context,
          backfill : Models::ClockInBackfill,
          clock_type : Helpers::ClockType,
          message : String,
          required : Bool = false,
        ) : Models::ClockInBackfill::Entry?
          loop do
            answer = context.input.request(message)

            if answer.nil?
              return nil unless required

              context.display.error!("Cancelled — nothing submitted.")
            end

            case entry = backfill.add(clock_type, answer)
            in Models::ClockInBackfill::Entry
              return entry
            in Error::Base
              context.display.error(entry)
            end
          end
        end

        private def summarise(context : Context, entries : Array(Models::ClockInBackfill::Entry)) : Nil
          context.display.puts "About to submit:"
          entries.each do |entry|
            context.display.puts "  #{entry.clock_type.label}: #{Utils::Time.pretty_time(entry.time)}"
          end
        end

        private def confirm?(context : Context) : Bool
          answer = context.input.request("Submit? (Y/n)")
          answer.nil? || answer.downcase.in?("y", "yes")
        end

        private def submit(context : Context, entries : Array(Models::ClockInBackfill::Entry)) : Nil
          entries.each do |entry|
            context.client.clock_ins.create(
              context.current.user.id,
              entry.time,
              entry.clock_type.to_underscore,
              mobile_clockin: true
            ).or { |error| context.display.error!(error) }
          end
        end
      end
    end
  end
end
