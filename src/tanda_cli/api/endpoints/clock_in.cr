require "../client"

module TandaCLI
  module API
    module Endpoints::ClockIn
      def clockins(date : Time) : API::Result(Array(Types::ClockIn))
        date_string = date.to_s("%Y-%m-%d")

        response = get("/clockins", query: {
          "user_id" => Current.user.id.to_s,
          "from"    => date_string,
          "to"      => date_string,
        })

        API::Result(Array(Types::ClockIn)).from(response)
      end

      def send_clock_in(
        time : Time,
        type : String,
        photo : String? = nil,
        mobile_clockin : Bool = false
      ) : API::Result(Nil)
        response = post("/clockins", body: {
          "time"           => time.to_unix.to_s,
          "type"           => type,
          "user_id"        => Current.user.id.to_s,
          "mobile_clockin" => mobile_clockin.to_s,
        }.tap do |options|
          options["photo"] = photo if photo
        end)

        API::Result(Nil).from(response)
      end
    end
  end
end
