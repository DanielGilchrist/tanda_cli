module TandaCLI
  module Models
    struct LeaveShift
      class MismatchedLeaveShift < ArgumentError
        def initialize(shift : API::Types::Shift, leave_request : API::Types::LeaveRequest)
          super("Leave request is for a different shift!\nShift: #{shift.inspect}\nLeaveRequest: #{leave_request.inspect}")
        end
      end

      def self.from?(api_shift : API::Types::Shift, leave_request : API::Types::LeaveRequest) : LeaveShift?
        leave_request_id = api_shift.leave_request_id
        return if leave_request_id.nil?
        raise(MismatchedLeaveShift.new(api_shift, leave_request)) if leave_request_id != leave_request.id

        breakdown = leave_request.find(&.shift_id.==(api_shift.id))
        return unless breakdown

        new(api_shift, breakdown, leave_request)
      end

      def initialize(
        @api_shift : API::Types::Shift,
        @breakdown : API::Types::LeaveRequest::DailyBreakdown,
        @leave_request : API::Types::LeaveRequest,
      ); end

      getter breakdown : API::Types::LeaveRequest::DailyBreakdown
      getter leave_request : API::Types::LeaveRequest

      def day_of_week : Time::DayOfWeek
        @api_shift.date.day_of_week
      end

      def leave_taken : Time::Span
        breakdown.hours
      end

      def daily_breakdown_representer : Representers::LeaveRequest::DailyBreakdown
        Representers::LeaveRequest::DailyBreakdown.new(breakdown, leave_request)
      end
    end
  end
end
