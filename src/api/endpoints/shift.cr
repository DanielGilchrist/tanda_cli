require "./interface.cr"
require "../client"

module Tanda::CLI
  module API
    module Endpoints::Shift
      include Endpoints::Interface

      def todays_shifts(show_notes : Bool = false) : API::Result(Array(Types::Shift))
        shifts(Utils::Time.now)
      end

      def shifts(date : Time, show_notes : Bool = false) : API::Result(Array(Types::Shift))
        request_shifts(date, date, show_notes: show_notes)
      end

      def shifts(start_date : Time, finish_date : Time, show_notes : Bool = false) : API::Result(Array(Types::Shift))
        request_shifts(start_date, finish_date, show_notes: show_notes)
      end

      private def request_shifts(start_date : Time, finish_date : Time, show_notes : Bool = false) : API::Result(Array(Types::Shift))
        start_string, finish_string = {
          start_date,
          finish_date,
        }
          .map(&.to_s("%Y-%m-%d"))

        response = get("/shifts", query: {
          "user_ids"   => Current.user.id.to_s,
          "from"       => start_string,
          "to"         => finish_string,
          "show_notes" => show_notes.to_s,
          # This is an arbitrarily named query param to get past issue where shift data would be stale from server-side cache
          "cache_key" => Random.rand(1000).to_s,
        })

        Types::Shift.from_array(response, self)
      end
    end
  end
end
