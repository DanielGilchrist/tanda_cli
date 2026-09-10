require "../utils/mixins/pretty_times"
require "./break_length"
require "./shift_break"

module TandaCLI
  module Models
    struct MeasuredBreak
      include Utils::Mixins::PrettyTimes

      def initialize(@shift_break : ShiftBreak, @length : BreakLength::Any) : Nil; end

      getter length : BreakLength::Any

      delegate :id, :paid?, :start_time, :finish_time, to: @shift_break

      def span : Time::Span
        length.span
      end
    end
  end
end
