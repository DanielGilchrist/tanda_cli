require "../request"

module TandaCLI
  module API
    module Resources
      struct LeaveBalances
        def initialize(@request : Request); end

        def list(user_id : Int32) : Result(Array(Types::LeaveBalance))
          @request.get(Array(Types::LeaveBalance), "/leave_balances", query: {
            "user_ids" => user_id.to_s,
          })
        end
      end
    end
  end
end
