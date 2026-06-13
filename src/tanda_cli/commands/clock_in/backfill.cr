require "../../models/clock_in_backfill"

module TandaCLI
  module Commands
    class ClockIn
      class Backfill < Commands::Base
        requires_auth!

        def setup_
          @name = "backfill"
          @summary = @description = "Backfill missed clock ins for a day"

          add_option 'd', "date", type: :single, description: "Day to backfill, defaults to today (\"yesterday\" or YYYY-MM-DD)"
        end

        def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
          day = parse_day(options)
          api_shifts = client.shifts.list(current.user.id, day).or { |error| display.error!(error) }
          shifts = api_shifts.compact_map { |api_shift| Models::WorkedShift.from?(api_shift) }
          backfill = Models::ClockInBackfill.new(day, shifts)

          display.puts "📅 #{Utils::Time.pretty_date(day).colorize.white.bold}"

          return display.puts "Nothing to backfill — this day is already complete." if backfill.complete?

          announce_existing_state(backfill)
          interview(backfill)

          entries = backfill.entries
          return display.puts "Nothing to backfill." if entries.empty?

          display.puts
          summarise(entries)
          return display.puts "Cancelled — nothing submitted." unless confirm?

          submit(entries)

          clock_in_word = entries.one? ? "clock in" : "clock ins"
          display.success("Backfilled #{entries.size} #{clock_in_word} for #{Utils::Time.pretty_date(day)}")
        end

        private def parse_day(options : Cling::Options) : ::Time
          date_string = options.get?("date").try(&.as_s)
          return Utils::Time.now if date_string.nil?

          day =
            case parsed = Models::ClockInMoment.parse_day(date_string)
            in ::Time
              parsed
            in Error::Base
              display.error!(parsed)
            end

          display.error!("You can't backfill a future date") if day.date > Utils::Time.now.date

          day
        end

        private def announce_existing_state(backfill : Models::ClockInBackfill) : Nil
          shift = backfill.ongoing_shift
          return display.puts "No clock ins recorded." if shift.nil?

          display.puts "You clocked in at #{shift.pretty_start_time}."

          if backfill.on_break?
            ongoing_break = shift.breaks.find(&.ongoing?)
            display.puts "Your break started at #{ongoing_break.pretty_start_time}." if ongoing_break
          end
        end

        private def interview(backfill : Models::ClockInBackfill) : Nil
          prompt(backfill, :start, "🕐 What time did you start?", required: true) if backfill.needs_start?

          if backfill.on_break?
            prompt(backfill, :break_finish, "☕ What time did your break finish? (blank to leave it open)")
          end

          while backfill.can_break?
            break unless prompt(backfill, :break_start, "☕ Did you take a break? Start time (blank to skip)")

            prompt(backfill, :break_finish, "☕ What time did the break finish?", required: true)
          end

          if backfill.can_finish?
            prompt(backfill, :finish, "🕐 What time did you finish? (blank if you're still working)")
          end
        end

        private def prompt(
          backfill : Models::ClockInBackfill,
          clock_type : Helpers::ClockType,
          message : String,
          required : Bool = false,
        ) : Models::ClockInBackfill::Entry?
          loop do
            answer = input.request(message)

            if answer.nil?
              return nil unless required

              display.error!("Cancelled — nothing submitted.")
            end

            case entry = backfill.add(clock_type, answer)
            in Models::ClockInBackfill::Entry
              return entry
            in Error::Base
              display.error(entry)
            end
          end
        end

        private def summarise(entries : Array(Models::ClockInBackfill::Entry)) : Nil
          display.puts "About to submit:"
          entries.each do |entry|
            display.puts "  #{entry.clock_type.label}: #{Utils::Time.pretty_time(entry.time)}"
          end
        end

        private def confirm? : Bool
          answer = input.request("Submit? (Y/n)")
          answer.nil? || answer.downcase.in?("y", "yes")
        end

        private def submit(entries : Array(Models::ClockInBackfill::Entry)) : Nil
          entries.each do |entry|
            client.clock_ins.create(
              current.user.id,
              entry.time,
              entry.clock_type.to_underscore,
              mobile_clockin: true
            ).or { |error| display.error!(error) }
          end
        end
      end
    end
  end
end
