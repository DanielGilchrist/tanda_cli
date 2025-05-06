module TandaCLI
  module Models
    struct ClockInStatus
      enum Status
        ClockedIn
        ClockedOut
        BreakStarted
      end

      def initialize(@shifts : Array(Types::Shift)); end

      def determine_status : Status
        if break_started?
          Status::BreakStarted
        elsif clocked_in?
          Status::ClockedIn
        else
          Status::ClockedOut
        end
      end

      private def break_started? : Bool
        @shifts.any?(&.ongoing_break?)
      end

      private def clocked_in? : Bool
        @shifts.any? { |shift| shift.start_time && shift.finish_time.nil? }
      end
    end
  end
end
