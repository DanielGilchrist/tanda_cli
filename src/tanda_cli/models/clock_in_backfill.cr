require "./clock_in_backfill/break"
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

      def initialize(@day : ::Time, shifts : Array(WorkedShift)) : Nil
        status = ClockInStatus.from_shifts(shifts)
        @complete = shifts.any?(&.start_time) && status.clocked_out?
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

      def finish_time : ::Time?
        @entries.find(&.clock_type.finish?).try(&.time)
      end

      def finished_break : FinishedBreak?
        ongoing_break = @ongoing_shift.try(&.valid_breaks.find(&.ongoing?))
        return if ongoing_break.nil?

        entry = break_entries.first?
        return unless entry && entry.clock_type.break_finish?

        FinishedBreak.new(ongoing_break.id, entry.time)
      end

      def new_breaks : Array(Break)
        entries = break_entries
        entries = entries.skip(1) if finished_break

        entries.each_slice(2).map do |(start_entry, finish_entry)|
          Break.new(start_entry.time, finish_entry.try(&.time))
        end.to_a
      end

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

      private def break_entries : Array(Entry)
        @entries.select { |entry| entry.clock_type.break_start? || entry.clock_type.break_finish? }
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
