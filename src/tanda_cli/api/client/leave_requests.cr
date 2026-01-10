module TandaCLI
  module API
    class Client
      struct LeaveRequests
        def initialize(@request : Request)
        end

        def list(ids : Array(Int32)) : API::Result(Array(Types::LeaveRequest))
          @request.get(Array(Types::LeaveRequest), "/leave", query: {
            "ids" => ids.join(","),
          })
        end
      end
    end
  end
end
