require "../utils/mixins/pretty_times"

module TandaCLI
  module Models
    struct ShiftBreak
      include Utils::Mixins::PrettyTimes

      def initialize(@api_shift_break : API::Types::ShiftBreak); end

      delegate :id, :shift_id, :length, :paid?, :start_time, :finish_time, to: @api_shift_break

      def valid? : Bool
        !!start_time || !length.zero?
      end

      def ongoing? : Bool
        return false unless start_time

        finish_time.nil?
      end

      def ongoing_length : Time::Span
        start_time = self.start_time
        finish_time = self.finish_time
        return length if finish_time || start_time.nil?

        Utils::Time.now - start_time
      end

      def pretty_ongoing_length : String
        "#{ongoing_length.total_minutes.to_i} minutes"
      end
    end
  end
end
