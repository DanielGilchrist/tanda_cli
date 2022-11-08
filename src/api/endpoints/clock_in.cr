require "./interface.cr"
require "../client"

module Tanda::CLI
  module API
    module Endpoints::ClockIn
      include Endpoints::Interface

      def clockins(date : Time) : Array(Types::ClockIn) | Types::Error
        date_string = date.to_s("%Y-%m-%d")

        response = get("/clockins", query: {
          "user_id" => Current.user.id.to_s,
          "from" => date_string,
          "to" => date_string
        })
        return Types::Error.from_json(response.body) unless response.success?

        Array(Types::ClockIn).from_json(response.body)
      end

      def send_clock_in(time : Time, type : String) : Types::Error?
        response = post("/clockins", body: {
          "time" => time.to_unix.to_s,
          "type" => type,
          "user_id" => Current.user.id.to_s
        })
        return if response.success?

        Types::Error.from_json(response.body)
      end
    end
  end
end
