require "../error/invalid_edit_choice"
require "../error/out_of_order_clock_in"
require "./clock_in_moment"
require "./shift_edit/break"
require "./shift_edit/break_change"
require "./shift_edit/field"
require "./worked_shift"

module TandaCLI
  module Models
    class ShiftEdit
      alias Choice = Field | BreakChange

      @break_originals : Array(Break?)

      def initialize(@shift : WorkedShift) : Nil
        @start = shift.start_time
        @finish = shift.finish_time
        @breaks = original_breaks
        @break_originals = @breaks.map { |shift_break| shift_break.as(Break?) }
      end

      getter start : ::Time?
      getter finish : ::Time?
      getter breaks : Array(Break)

      def id : Int32
        @shift.id
      end

      def day : ::Time
        @shift.date
      end

      def original_start : ::Time?
        @shift.start_time
      end

      def original_finish : ::Time?
        @shift.finish_time
      end

      def original_breaks : Array(Break)
        @shift.valid_breaks.compact_map do |shift_break|
          start = shift_break.start_time
          next if start.nil?

          Break.new(shift_break.id, start, shift_break.finish_time, shift_break.paid?)
        end
      end

      def breaks_editable? : Bool
        @shift.valid_breaks.all?(&.start_time)
      end

      def change_start(input : String) : ::Time? | Error::Base
        case time = parse_time_or_none(input)
        in ::Time?
          @start = time
        in Error::Base
          time
        end
      end

      def change_finish(input : String) : ::Time? | Error::Base
        case time = parse_time_or_none(input)
        in ::Time?
          @finish = time
        in Error::Base
          time
        end
      end

      def change_break_start(index : Int32, input : String) : ::Time | Error::Base
        case time = parse_time(input)
        in ::Time
          @breaks[index] = @breaks[index].copy_with(start: time)
          time
        in Error::Base
          time
        end
      end

      def change_break_finish(index : Int32, input : String) : ::Time? | Error::Base
        case time = parse_time_or_none(input)
        in ::Time?
          @breaks[index] = @breaks[index].copy_with(finish: time)
          time
        in Error::Base
          time
        end
      end

      def remove_break(index : Int32) : Break
        @break_originals.delete_at(index)
        @breaks.delete_at(index)
      end

      def add_break(input : String) : ::Time | Error::Base
        case time = parse_time(input)
        in ::Time
          @breaks << Break.new(nil, time, nil, false)
          @break_originals << nil
          time
        in Error::Base
          time
        end
      end

      def break_changes : Array(BreakChange)
        @breaks
          .zip(@break_originals)
          .map_with_index { |(shift_break, original), index| {shift_break, original, index} }
          .sort_by!(&.first.start)
          .map_with_index(1) { |(shift_break, original, index), number| BreakChange.new(shift_break, original, index, number) }
      end

      def targets : Array(Choice)
        break_targets = breaks_editable? ? break_changes.map(&.as(Choice)) : [] of Choice

        [Field::Start.as(Choice)] + break_targets + [Field::Finish.as(Choice)]
      end

      def choose(input : String) : Choice | Error::Base
        return Field::NewBreak if breaks_editable? && input.downcase == "b"

        targets = self.targets
        number = input.to_i?
        target = targets[number - 1]? if number && number >= 1

        target || Error::InvalidEditChoice.new(input, targets.size, breaks_editable?)
      end

      def removed_breaks : Array(Break)
        original_breaks.reject { |shift_break| @break_originals.includes?(shift_break) }
      end

      def representer : Representers::ShiftEdit
        Representers::ShiftEdit.new(self)
      end

      def changed? : Bool
        start_changed? || finish_changed? || breaks_changed?
      end

      def start_changed? : Bool
        @start != original_start
      end

      def finish_changed? : Bool
        @finish != original_finish
      end

      def breaks_changed? : Bool
        @breaks != original_breaks
      end

      def validate : Error::Base?
        previous = nil

        timeline.each do |time|
          return Error::OutOfOrderClockIn.new(time, previous) if previous && time <= previous

          previous = time
        end
      end

      private def timeline : Array(::Time)
        break_times = @breaks.sort_by(&.start).flat_map { |shift_break| [shift_break.start, shift_break.finish] }

        ([@start] + break_times + [@finish]).compact
      end

      private def parse_time_or_none(input : String) : ::Time? | Error::Base
        return if input.downcase == "none"

        parse_time(input)
      end

      private def parse_time(input : String) : ::Time | Error::Base
        case moment = ClockInMoment.parse(input, on: day)
        in ClockInMoment
          moment.time
        in Error::Base
          moment
        end
      end
    end
  end
end
