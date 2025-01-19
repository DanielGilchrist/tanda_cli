require "../client"

module TandaCLI
  module API
    module Endpoints::ClockIn
      def clockins(user_id : Int32, date : Time) : API::Result(Array(Types::ClockIn))
        date_string = date.to_s("%Y-%m-%d")

        response = get("/clockins", query: {
          "user_id" => user_id.to_s,
          "from"    => date_string,
          "to"      => date_string,
        })

        API::Result(Array(Types::ClockIn)).from(response)
      end

      def send_clock_in(
        user_id : Int32,
        time : Time,
        type : String,
        photo : String? = nil,
        mobile_clockin : Bool = false,
      ) : API::Result(Nil)
        response = post("/clockins", body: {
          "time"           => time.to_unix.to_s,
          "type"           => type,
          "user_id"        => user_id.to_s,
          "mobile_clockin" => mobile_clockin.to_s,
        }.tap do |options|
          options["photo"] = photo if photo
        end)

        API::Result(Nil).from(response)
      end
    end
  end
end
