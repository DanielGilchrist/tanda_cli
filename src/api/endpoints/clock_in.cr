require "./interface.cr"
require "../client"

module Tanda::CLI
  module API
    module Endpoints::ClockIn
      include Endpoints::Interface

      def clockins(date : Time) : API::Result(Array(Types::ClockIn))
        date_string = date.to_s("%Y-%m-%d")

        response = get("/clockins", query: {
          "user_id" => Current.user.id.to_s,
          "from" => date_string,
          "to" => date_string
        })

        API::Result(Array(Types::ClockIn)).from(response)
      end

      def send_clock_in(time : Time, type : String) : API::Result(Nil)
        response = post("/clockins", body: {
          "time" => time.to_unix.to_s,
          "type" => type,
          "user_id" => Current.user.id.to_s
        })

        API::Result(Nil).from(response)
      end
    end
  end
end
