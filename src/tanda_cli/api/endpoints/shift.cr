require "../client"

module TandaCLI
  module API
    module Endpoints::Shift
      def shifts(user_id : Int32, date : Time, show_notes : Bool = false) : API::Result(Array(Types::Shift))
        request_shifts(user_id, date, date, show_notes: show_notes)
      end

      def shifts(user_id : Int32, start_date : Time, finish_date : Time, show_notes : Bool = false) : API::Result(Array(Types::Shift))
        request_shifts(user_id, start_date, finish_date, show_notes: show_notes)
      end

      private def request_shifts(user_id : Int32, start_date : Time, finish_date : Time, show_notes : Bool = false) : API::Result(Array(Types::Shift))
        start_string, finish_string = {
          start_date,
          finish_date,
        }
          .map(&.to_s("%Y-%m-%d"))

        response = get("/shifts", query: {
          "user_ids"   => user_id.to_s,
          "from"       => start_string,
          "to"         => finish_string,
          "show_notes" => show_notes.to_s,
          # This is an arbitrarily named query param to get past issue where shift data would be stale from server-side cache
          "cache_key" => cache_key,
        })

        Types::Shift.from_array(response, self)
      end

      private def cache_key : String
        Time::Format.new("%Y-%m-%d-%H-%M").format(Time.local)
      end
    end
  end
end
