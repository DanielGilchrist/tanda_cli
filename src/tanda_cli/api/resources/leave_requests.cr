require "../request"

module TandaCLI
  module API
    module Resources
      struct LeaveRequests
        PAGE_SIZE = 100

        def initialize(@request : Request) : Nil; end

        def list(ids : Array(Int32)) : Result(Array(Types::LeaveRequest))
          @request.get(Array(Types::LeaveRequest), "/leave", query: {
            "ids" => ids.join(","),
          })
        end

        def list(user_id : Int32, window : Models::LeaveWindow) : Result(Array(Types::LeaveRequest))
          leave_requests = Array(Types::LeaveRequest).new
          page = 1

          loop do
            result = fetch_page(user_id, window, page)
            fetched = result.or { return result }

            leave_requests.concat(fetched)
            break if fetched.size < PAGE_SIZE

            page += 1
          end

          Result(Array(Types::LeaveRequest)).new(leave_requests)
        end

        private def fetch_page(user_id : Int32, window : Models::LeaveWindow, page : Int32) : Result(Array(Types::LeaveRequest))
          @request.get(Array(Types::LeaveRequest), "/leave", query: {
            "from"      => Utils::Time.iso_date(window.from),
            "to"        => Utils::Time.iso_date(window.to),
            "user_ids"  => user_id.to_s,
            "page"      => page.to_s,
            "page_size" => PAGE_SIZE.to_s,
          })
        end
      end
    end
  end
end
