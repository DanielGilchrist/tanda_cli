module TandaCLI
  module Commands
    module Helpers
      module TimeWorked
        private def leave_requests_for(shifts : Array(API::Types::Shift)) : Array(API::Types::LeaveRequest)
          leave_request_ids = shifts.compact_map(&.leave_request_id)
          return Array(API::Types::LeaveRequest).new if leave_request_ids.empty?

          client.leave_requests.list(ids: leave_request_ids).or { |error| display.error!(error) }
        end
      end
    end
  end
end
