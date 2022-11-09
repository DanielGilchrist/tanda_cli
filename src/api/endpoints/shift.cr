require "./interface.cr"
require "../client"

module Tanda::CLI
  module API
    module Endpoints::Shift
      include Endpoints::Interface

      def shifts(date : Time) : API::Result(Array(Types::Shift))
        request_shifts(date, date)
      end

      def shifts(start_date : Time, finish_date : Time) : API::Result(Array(Types::Shift))
        request_shifts(start_date, finish_date)
      end

      private def request_shifts(start_date : Time, finish_date : Time) : API::Result(Array(Types::Shift))
        start_string, finish_string = [
          start_date,
          finish_date
        ]
        .map(&.to_s("%Y-%m-%d"))

        response = get("/shifts", query: {
          "user_ids" => Current.user.id.to_s,
          "from"     => start_string,
          "to"       => finish_string
        })

        API::Result(Array(Types::Shift)).from(response)
      end
    end
  end
end
