module TandaCLI
  module API
    class Client
      struct Shifts
        def initialize(@request : Request, @client : Client)
        end

        def list(user_id : Int32, date : Time, show_notes : Bool = false) : API::Result(Array(Types::Shift))
          fetch(user_id, date, date, show_notes: show_notes)
        end

        def list(user_id : Int32, start_date : Time, finish_date : Time, show_notes : Bool = false) : API::Result(Array(Types::Shift))
          fetch(user_id, start_date, finish_date, show_notes: show_notes)
        end

        private def fetch(user_id : Int32, start_date : Time, finish_date : Time, show_notes : Bool = false) : API::Result(Array(Types::Shift))
          start_string, finish_string = {
            start_date,
            finish_date,
          }
            .map(&.to_s("%Y-%m-%d"))

          @request.get(Array(Types::Shift), "/shifts", query: {
            "user_ids"   => user_id.to_s,
            "from"       => start_string,
            "to"         => finish_string,
            "show_notes" => show_notes.to_s,
            # This is an arbitrarily named query param to get past issue where shift data would be stale from server-side cache
            "cache_key" => cache_key,
          }) do |shifts|
            attach_leave_requests_to_shifts(shifts)
          end
        end

        private def attach_leave_requests_to_shifts(shifts : Array(Types::Shift)) : Array(Types::Shift) | Types::Error
          leave_request_ids = shifts.compact_map(&.leave_request_id)
          return shifts if leave_request_ids.empty?

          leave_requests_by_id = @client.leave_requests.list(ids: leave_request_ids).or { |error| return error }.index_by(&.id)

          if leave_requests_by_id.present?
            shifts.each do |shift|
              leave_request_id = shift.leave_request_id
              next if leave_request_id.nil?

              leave_request = leave_requests_by_id[leave_request_id]?
              next if leave_request.nil?

              shift.set_leave_request!(leave_request)
            end
          end

          shifts
        end

        private def cache_key : String
          Time::Format.new("%Y-%m-%d-%H-%M").format(Time.local)
        end
      end
    end
  end
end
