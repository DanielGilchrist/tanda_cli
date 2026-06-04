require "../client"

module TandaCLI
  module API
    module Endpoints::LeaveRequest
      def leave_requests(ids : Array(Int32)) : API::Result(Array(API::Types::LeaveRequest))
        response = get("/leave", query: {
          "ids" => ids.join(","),
        })

        API::Result(Array(API::Types::LeaveRequest)).from(response)
      end
    end
  end
end
