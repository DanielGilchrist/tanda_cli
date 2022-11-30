require "./interface.cr"
require "../client"

module Tanda::CLI
  module API
    module Endpoints::LeaveRequest
      include Endpoints::Interface

      def leave_requests(ids : Array(Int32)) : API::Result(Array(Types::LeaveRequest))
        response = get("/leave", query: {
          "ids" => ids.join(",")
        })

        API::Result(Array(Types::LeaveRequest)).from(response)
      end
    end
  end
end
