module TandaCLI
  module Commands
    struct ClockIn
      @[Kebab::Command(summary: "Check current clockin status")]
      struct Status
        include Kebab::Parseable

        def run(context : Context) : Nil
          display = context.display

          api_shifts = context.client.shifts.list(context.current.user.id, Utils::Time.now).or { |error| display.error!(error) }
          todays_shifts = api_shifts
            .compact_map { |api_shift| Models::WorkedShift.from?(api_shift) }
            .sort_by!(&.id)

          ongoing_shift = todays_shifts.reverse_each.find(&.ongoing?)
          return handle_ongoing_shift(display, ongoing_shift) if ongoing_shift

          last_shift = todays_shifts.last?
          return display.puts "You aren't currently clocked in" if last_shift.nil?

          handle_clocked_out(display, last_shift)
        end

        private def handle_ongoing_shift(display : TandaCLI::Display, shift : Models::WorkedShift)
          if (shift_breaks = shift.breaks).present?
            ongoing_breaks, finished_breaks = shift_breaks.partition(&.ongoing?)
            if ongoing_break = ongoing_breaks.last?
              display.puts "☕ #{"On break".colorize.yellow}"
              display.puts "🕐 Started at #{ongoing_break.pretty_start_time}"
            else
              finished_break = finished_breaks.last

              display.puts "✅ #{"Clocked in".colorize.green}"
              display.puts "☕ Finished break at #{finished_break.pretty_finish_time}"
            end
          else
            display.puts "✅ #{"Clocked in".colorize.green}"
            display.puts "🕐 Since #{shift.pretty_start_time}"
          end
        end

        private def handle_clocked_out(display : TandaCLI::Display, last_shift : Models::WorkedShift)
          display.puts "🔴 #{"Clocked out".colorize.red}"
          display.puts "🕐 At #{last_shift.pretty_finish_time}"
        end
      end
    end
  end
end
