require "./leave_type"
require "./leave_window"

module TandaCLI
  module Models
    # A leave request that has not been submitted. Every value that can be built is a legal request.
    struct LeaveDraft
      def self.build(window : LeaveWindow, leave_type : LeaveType, hours : Time::Span, reason : String?) : LeaveDraft
        new(window, leave_type, hours, reason.try(&.strip.presence))
      end

      private def initialize(
        @window : LeaveWindow,
        @leave_type : LeaveType,
        @hours : Time::Span,
        @reason : String?,
      ) : Nil; end

      getter window : LeaveWindow
      getter leave_type : LeaveType
      getter hours : Time::Span
      getter reason : String?

      def start : Time
        @window.from
      end

      def finish : Time
        @window.to
      end

      def single_day? : Bool
        start == finish
      end

      def days : Int32
        ((finish - start).total_days.round.to_i) + 1
      end

      def with_hours(hours : Time::Span) : LeaveDraft
        new(@window, @leave_type, hours, @reason)
      end

      def retry_command : String
        parts = [
          "tanda_cli leave request",
          "--from #{Utils::Time.iso_date(start)}",
        ]

        parts << "--to #{Utils::Time.iso_date(finish)}" unless single_day?
        parts << "--type #{@leave_type.name.inspect}"

        reason = @reason
        parts << "--reason #{reason.inspect}" if reason

        parts.join(" ")
      end
    end
  end
end
