module TandaCLI
  module Models
    struct ShiftSummary
      struct LeaveShift
        def self.from?(shift : Types::Shift) : LeaveShift?
          leave_request = shift.leave_request
          breakdown = leave_request.breakdown_for(shift) if leave_request
          return unless leave_request && breakdown

          LeaveShift.new(shift, breakdown, leave_request)
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
      end
    end
  end
end
