require "../request"

module TandaCLI
  module API
    module Resources
      struct LeaveRequests
        def initialize(@request : Request); end

        def list(ids : Array(Int32)) : Result(Array(Types::LeaveRequest))
          @request.get(Array(Types::LeaveRequest), "/leave", query: {
            "ids" => ids.join(","),
          })
        end
      end
    end
  end
end
