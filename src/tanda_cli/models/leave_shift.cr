module TandaCLI
  module Models
    struct LeaveShift
      class MismatchedLeaveShift < ArgumentError
        def initialize(shift : Types::Shift, leave_request : Types::LeaveRequest)
          super("Leave request is for a different shift!\nShift: #{shift.inspect}\nLeaveRequest: #{leave_request.inspect}")
        end
      end

      def self.from?(shift : Types::Shift, leave_request : Types::LeaveRequest?) : LeaveShift?
        raise(ArgumentError.new("#{shift.inspect} is not a leave shift!")) unless shift.leave?
        raise(MismatchedLeaveShift.new(shift, leave_request)) if shift.leave_request_id != leave_request.id

        breakdown = leave_request.find(&.shift_id.==(shift.id))
        return unless breakdown

        new(shift, breakdown, leave_request)
      end

      def initialize(
        @shift : Types::Shift,
        @breakdown : Types::LeaveRequest::DailyBreakdown,
        @leave_request : Types::LeaveRequest,
      )
      end

      getter shift : Types::Shift
      getter breakdown : Types::LeaveRequest::DailyBreakdown
      getter leave_request : Types::LeaveRequest

      def leave_taken : Time::Span
        breakdown.hours
      end

      def daily_breakdown_representer : Representers::LeaveRequest::DailyBreakdown
        Representers::LeaveRequest::DailyBreakdown.new(breakdown, leave_request)
      end
    end
  end
end
