require "../../models/clock_in_backfill"
require "../../converters/day"
require "../helpers/clock_in_day"

module TandaCLI
  module Commands
    struct ClockIn
      @[Kebab::Command(summary: "Backfill missed clock ins for a day")]
      struct Backfill
        include Kebab::Parseable
        include Helpers::ClockInDay

        @[Kebab::Option(short: 'd', converter: ::TandaCLI::Converters::Day, description: "Day to backfill, defaults to today (\"wed\", \"yesterday\" or YYYY-MM-DD)")]
        getter date : Models::ClockInDay?

        def run(context : Context) : Nil
          display = context.display

          day = resolve_day(context)
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

          submit(context, backfill)

          clock_in_word = entries.one? ? "clock in" : "clock ins"
          display.success("Backfilled #{entries.size} #{clock_in_word} for #{Utils::Time.pretty_date(day)}")
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
              return unless required

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

        private def submit(context : Context, backfill : Models::ClockInBackfill) : Nil
          shift = backfill.ongoing_shift

          if shift && backfill.day.date < Utils::Time.now.date
            update_shift(context, shift, backfill)
          else
            backfill.entries.each do |entry|
              context.client.clock_ins.create(
                context.current.user.id,
                entry.time,
                entry.clock_type.to_underscore,
                mobile_clockin: true
              ).or { |error| context.display.error!(error) }
            end
          end
        end

        private def update_shift(context : Context, shift : Models::WorkedShift, backfill : Models::ClockInBackfill) : Nil
          display = context.display
          client = context.client

          if finish = backfill.finish_time
            client.shifts.update(shift.id, &.finish(finish)).or { |error| display.error!(error) }
          end

          if finished_break = backfill.finished_break
            client.shift_breaks
              .update(shift.id, finished_break.id, &.finish(finished_break.finish))
              .or { |error| display.error!(error) }
          end

          backfill.new_breaks.each do |shift_break|
            client.shift_breaks.create(shift.id) do |update|
              update.start(shift_break.start)
              update.finish(shift_break.finish)
            end.or { |error| display.error!(error) }
          end
        end
      end
    end
  end
end
