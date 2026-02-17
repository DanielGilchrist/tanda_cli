module TandaCLI
  module Commands
    class ClockIn
      class Status < Commands::Base
        def setup_
          @name = "status"
          @summary = @description = "Check current clockin status"
        end

        def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
          todays_shifts = client.shifts(current.user.id, Utils::Time.now).or { |error| display.error!(error) }.sort_by(&.id)
          ongoing_shift = todays_shifts.reverse_each.find(&.ongoing?)
          return handle_ongoing_shift(ongoing_shift) if ongoing_shift

          last_shift = todays_shifts.last?
          return display.puts "You aren't currently clocked in" if last_shift.nil?

          handle_clocked_out(last_shift)
        end

        private def handle_ongoing_shift(shift : Types::Shift)
          if (shift_breaks = shift.breaks).present?
            ongoing_breaks, finished_breaks = shift_breaks.partition(&.ongoing?)
            if ongoing_break = ongoing_breaks.last?
              display.puts "You are on break"
              display.puts "You started a break at #{ongoing_break.pretty_start_time}"
            else
              finished_break = finished_breaks.last

              display.puts "You are clocked in"
              display.puts "You finished a break at #{finished_break.pretty_finish_time}"
            end
          else
            display.puts "You are clocked in"
            display.puts "You clocked in at #{shift.pretty_start_time}"
          end
        end

        private def handle_clocked_out(last_shift : Types::Shift)
          display.puts "You are clocked out"
          display.puts "You clocked out at #{last_shift.pretty_finish_time}"
        end
      end
    end
  end
end
