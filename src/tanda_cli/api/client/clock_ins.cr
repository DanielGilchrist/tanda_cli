module TandaCLI
  module API
    class Client
      struct ClockIns
        def initialize(@request : Request)
        end

        def list(user_id : Int32, date : Time) : API::Result(Array(Types::ClockIn))
          date_string = date.to_s("%Y-%m-%d")

          @request.get(Array(Types::ClockIn), "/clockins", query: {
            "user_id" => user_id.to_s,
            "from"    => date_string,
            "to"      => date_string,
          })
        end

        def create(
          user_id : Int32,
          time : Time,
          type : String,
          photo : String? = nil,
          mobile_clockin : Bool = false,
        ) : API::Result(Nil)
          @request.post(Nil, "/clockins", body: {
            "time"           => time.to_unix.to_s,
            "type"           => type,
            "user_id"        => user_id.to_s,
            "mobile_clockin" => mobile_clockin.to_s,
          }.tap do |options|
            options["photo"] = photo if photo
          end)
        end
      end
    end
  end
end
