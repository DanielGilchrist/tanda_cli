require "./clock_in_backfill/entry"
require "./clock_in_moment"
require "./clock_in_status"
require "./worked_shift"

module TandaCLI
  module Models
    class ClockInBackfill
      alias ClockType = Commands::Helpers::ClockType

      @finished = false
      @last_event_time : ::Time?

      def initialize(@day : ::Time, shifts : Array(WorkedShift))
        status = ClockInStatus.from_shifts(shifts)
        @complete = !shifts.empty? && status.clocked_out?
        @started = !status.clocked_out?
        @on_break = status.on_break?
        @last_event_time = shifts.compact_map(&.last_event_time).max?
        @ongoing_shift = shifts.find { |shift| shift.start_time && shift.finish_time.nil? }
        @entries = Array(Entry).new
      end

      getter day : ::Time
      getter entries : Array(Entry)
      getter ongoing_shift : WorkedShift?
      getter? complete : Bool
      getter? on_break : Bool

      def needs_start? : Bool
        !@started
      end

      def can_break? : Bool
        working?
      end

      def can_finish? : Bool
        working?
      end

      def add(clock_type : ClockType, input : String) : Entry | Error::Base
        moment =
          case parsed = ClockInMoment.parse(input, on: @day, after: last_event_time)
          in ClockInMoment
            parsed
          in Error::Base
            return parsed
          end

        apply(clock_type)
        Entry.new(clock_type, moment.time).tap { |entry| @entries << entry }
      end

      private def working? : Bool
        @started && !@on_break && !@finished
      end

      private def apply(clock_type : ClockType) : Nil
        case clock_type
        in .start?
          @started = true
        in .break_start?
          @on_break = true
        in .break_finish?
          @on_break = false
        in .finish?
          @finished = true
        end
      end

      private def last_event_time : ::Time?
        @entries.last?.try(&.time) || @last_event_time
      end
    end
  end
end
