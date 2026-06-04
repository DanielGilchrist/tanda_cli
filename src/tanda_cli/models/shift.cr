require "./worked_shift"
require "./leave_shift"

module TandaCLI
  module Models
    module Shift
      alias Any = WorkedShift | LeaveShift

      def self.parse?(
        api_shift : API::Types::Shift,
        leave_requests_by_id : Hash(Int32, API::Types::LeaveRequest),
        treat_paid_breaks_as_unpaid : Bool = false,
        regular_hours_schedules : Array(RegularHoursSchedule)? = nil,
      ) : Any?
        leave_request_id = api_shift.leave_request_id
        if leave_request_id && (leave_request = leave_requests_by_id[leave_request_id]?)
          LeaveShift.from?(api_shift, leave_request)
        else
          WorkedShift.from?(api_shift, treat_paid_breaks_as_unpaid, regular_hours_schedules)
        end
      end
    end
  end
end
