require "../utils/mixins/pretty_times"

module TandaCLI
  module Models
    struct ShiftBreak
      include Utils::Mixins::PrettyTimes

      def initialize(@api_shift_break : API::Types::ShiftBreak); end

      delegate :id, :shift_id, :length, :paid?, :start_time, :finish_time, to: @api_shift_break

      def valid? : Bool
        !!start_time || length > 0.minutes
      end

      def ongoing? : Bool
        return false unless start_time

        finish_time.nil?
      end
    end
  end
end
