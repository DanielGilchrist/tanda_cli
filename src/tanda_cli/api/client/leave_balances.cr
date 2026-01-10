module TandaCLI
  module API
    class Client
      struct LeaveBalances
        def initialize(@request : Request)
        end

        def list(user_id : Int32) : API::Result(Array(Types::LeaveBalance))
          @request.get(Array(Types::LeaveBalance), "/leave_balances", query: {
            "user_ids" => user_id.to_s,
          })
        end
      end
    end
  end
end
