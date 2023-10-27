require "../../client_builder"

module TandaCLI
  module Commands
    class ClockIn
      class Status < Commands::Base
        include ClientBuilder

        def setup_
          @name = "status"
          @summary = @description = "Check current clockin status"
        end

        def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
          todays_shifts = client.todays_shifts.or(&.display!).sort_by(&.id)
          ongoing_shift = todays_shifts.reverse_each.find(&.ongoing?)
          return handle_ongoing_shift(ongoing_shift) if ongoing_shift

          last_shift = todays_shifts.last?
          return Utils::Display.print "You aren't currently clocked in" if last_shift.nil?

          handle_clocked_out(last_shift)
        end

        private def handle_ongoing_shift(shift : Types::Shift)
          if !(shift_breaks = shift.breaks).empty?
            ongoing_breaks, finished_breaks = shift_breaks.partition(&.ongoing?)
            if ongoing_break = ongoing_breaks.last?
              Utils::Display.print "You are on break"
              Utils::Display.print "You started a break at #{ongoing_break.pretty_start_time}"
            else
              finished_break = finished_breaks.last

              Utils::Display.print "You are clocked in"
              Utils::Display.print "You finished a break at #{finished_break.pretty_finish_time}"
            end
          else
            Utils::Display.print "You are clocked in"
            Utils::Display.print "You clocked in at #{shift.pretty_start_time}"
          end
        end

        private def handle_clocked_out(last_shift : Types::Shift)
          Utils::Display.print "You are clocked out"
          Utils::Display.print "You clocked out at #{last_shift.pretty_finish_time}"
        end
      end
    end
  end
end
