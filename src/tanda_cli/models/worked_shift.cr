require "../utils/mixins/pretty_times"
require "./shift_break"

module TandaCLI
  module Models
    struct WorkedShift
      include Utils::Mixins::PrettyTimes

      def self.from?(api_shift : API::Types::Shift) : WorkedShift?
        return if api_shift.leave_request_id
        return if api_shift.start_time.nil? && api_shift.finish_time.nil?

        new(api_shift)
      end

      @valid_breaks : Array(ShiftBreak)? = nil

      def initialize(@api_shift : API::Types::Shift)
        @breaks = @api_shift.breaks.map { |api_break| ShiftBreak.new(api_break) }
      end

      delegate :id, :user_id, :date, :status, :start_time, :finish_time, :notes, to: @api_shift

      getter breaks : Array(ShiftBreak)

      def day_of_week : Time::DayOfWeek
        date.day_of_week
      end

      def valid_breaks : Array(ShiftBreak)
        @valid_breaks ||= breaks.select(&.valid?)
      end

      def ongoing? : Bool
        return false unless start_time
        return false unless finish_time.nil?

        date.date == Utils::Time.now.date
      end

      def ongoing_break? : Bool
        valid_breaks.any?(&.ongoing?)
      end

      def ongoing_without_break? : Bool
        ongoing? && valid_breaks.empty?
      end
    end
  end
end
