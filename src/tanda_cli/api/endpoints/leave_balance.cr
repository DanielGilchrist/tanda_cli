require "../client"

module TandaCLI
  module API
    module Endpoints::LeaveBalance
      def leave_balances(user_id : Int32) : API::Result(Array(Types::LeaveBalance))
        response = get("/leave_balances", query: {
          "user_ids" => user_id.to_s,
        })

        API::Result(Array(Types::LeaveBalance)).from(response)
      end
    end
  end
end
