require "./break_length"
require "./measured_break"
require "./shift_break"
require "./worked_shift"

module TandaCLI
  module Models
    # A shift's breaks measured against when the shift finished, or when we expect it to
    struct ShiftBreaks
      # No shift runs longer than this, so without an expected finish it's our last resort
      # for deciding a break can't still be running
      MAX_SHIFT_LENGTH = 1.day

      @measured : Array(MeasuredBreak)? = nil

      def initialize(
        @shift : WorkedShift,
        @breaks : Array(ShiftBreak),
        @expected_start_time : ::Time? = nil,
        @expected_finish_time : ::Time? = nil,
        @expected_break_length : Time::Span? = nil,
      ) : Nil; end

      def measured : Array(MeasuredBreak)
        @measured ||= begin
          assumed_span = assumed_span_per_unfinished_break

          @breaks.map { |shift_break| MeasuredBreak.new(shift_break, length_for(shift_break, assumed_span)) }
        end
      end

      def total : Time::Span
        measured.sum(&.span)
      end

      def any_never_finished? : Bool
        @breaks.any? { |shift_break| never_finished?(shift_break) }
      end

      def assumed_length : Time::Span?
        assumed_spans = measured.compact_map { |measured_break| measured_break.length.as?(BreakLength::Assumed) }
        return if assumed_spans.empty?

        assumed_spans.sum(&.span)
      end

      private def length_for(shift_break : ShiftBreak, assumed_span : Time::Span?) : BreakLength::Any
        start_time = shift_break.start_time
        return BreakLength::Recorded.new(shift_break.length) if start_time.nil? || shift_break.finish_time

        if running?(shift_break)
          BreakLength::Running.new(Utils::Time.now - start_time)
        elsif assumed_span
          BreakLength::Assumed.new(capped(assumed_span, start_time))
        else
          BreakLength::Unknown.new
        end
      end

      # Whatever we assume, the break can't have run past the end of the shift
      private def capped(span : Time::Span, start_time : ::Time) : Time::Span
        finish_reference = self.finish_reference
        return span if finish_reference.nil?

        remaining = finish_reference - start_time
        return Time::Span.zero if remaining.negative?

        {span, remaining}.min
      end

      # Regular hours tell us how much break the day should have had, so anything not
      # already accounted for is shared between the breaks that were never finished
      private def assumed_span_per_unfinished_break : Time::Span?
        expected_break_length = @expected_break_length
        return if expected_break_length.nil?

        never_finished, accounted_for = @breaks.partition { |shift_break| never_finished?(shift_break) }
        return if never_finished.empty?

        outstanding = expected_break_length - accounted_for.sum { |shift_break| known_span(shift_break) }
        return Time::Span.zero if outstanding.negative?

        outstanding / never_finished.size
      end

      private def known_span(shift_break : ShiftBreak) : Time::Span
        start_time = shift_break.start_time
        return shift_break.length if start_time.nil? || shift_break.finish_time
        return Utils::Time.now - start_time if running?(shift_break)

        Time::Span.zero
      end

      private def unfinished?(shift_break : ShiftBreak) : Bool
        !shift_break.start_time.nil? && shift_break.finish_time.nil?
      end

      private def running?(shift_break : ShiftBreak) : Bool
        return false unless unfinished?(shift_break)
        return false if @shift.finish_time
        return false unless plausibly_in_progress?

        expected_finish_time = @expected_finish_time
        return true if expected_finish_time.nil?
        return true if Utils::Time.now < expected_finish_time

        # Working past the expected finish means the expectation tells us nothing about this break
        start_time = shift_break.start_time
        !start_time.nil? && start_time >= expected_finish_time
      end

      private def never_finished?(shift_break : ShiftBreak) : Bool
        unfinished?(shift_break) && !running?(shift_break)
      end

      private def finish_reference : ::Time?
        @shift.finish_time || @expected_finish_time
      end

      private def plausibly_in_progress? : Bool
        start_time = @shift.start_time || @expected_start_time
        return false if start_time.nil?

        Utils::Time.now - start_time < MAX_SHIFT_LENGTH
      end
    end
  end
end
