require "./interface.cr"
require "../client"

module Tanda::CLI
  module API
    module Endpoints::ClockIn
      include Endpoints::Interface

      def send_clockin(time : Time, type : String) : Bool
        response = post("/clockins", body: {
          "time" => time.to_unix.to_s,
          "type" => type,
          "user_id" => Current.user.id.to_s
        })

        response.success?
      end
    end
  end
end
