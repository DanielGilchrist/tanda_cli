require "./interface.cr"
require "../client"
require "../../types/leave_request"

module Tanda::CLI
  module API
    module Endpoints::Leave
      def leave_request(id : Int32) : Types::LeaveRequest?
        response = get("/leave/#{id}")
        Types::LeaveRequest.from_json(response.body)
      end
    end
  end
end
