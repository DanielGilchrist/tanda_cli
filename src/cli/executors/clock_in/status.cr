module Tanda::CLI
  module CLI::Executors
    class ClockIn
      class Status
        def initialize(@client : API::Client); end

        def execute
          todays_shifts = client.todays_shifts.or(&.display!).sort_by(&.id)
          ongoing_shift = todays_shifts.reverse_each.find(&.ongoing?)
          return handle_ongoing_shift(ongoing_shift) if ongoing_shift

          last_shift = todays_shifts.last?
          return puts "You aren't currently clocked in" if last_shift.nil?

          handle_clocked_out(last_shift)
        end

        private getter client

        def handle_ongoing_shift(shift : Types::Shift)
          if !(shift_breaks = shift.breaks).empty?
            ongoing_breaks, finished_breaks = shift_breaks.partition(&.ongoing?)
            if ongoing_break = ongoing_breaks.last?
              puts "You are on break"
              puts "You started a break at #{ongoing_break.pretty_start_time}"
            else
              finished_break = finished_breaks.last

              puts "You are clocked in"
              puts "You finished a break at #{finished_break.pretty_finish_time}"
            end
          else
            puts "You are clocked in"
            puts "You clocked in at #{shift.pretty_start_time}"
          end
        end

        def handle_clocked_out(last_shift : Types::Shift)
          puts "You are clocked out"
          puts "You clocked out at #{last_shift.pretty_finish_time}"
        end
      end
    end
  end
end