require "./interface.cr"
require "../client"

module Tanda::CLI
  module API
    module Endpoints::ClockIn
      include Endpoints::Interface

      def send_clock_in(time : Time, type : String) : API::Result(Nil)
        response = post("/clockins", body: {
          "time" => time.to_unix.to_s,
          "type" => type,
          "user_id" => Current.user.id.to_s
        })

        result = Types::Error.from_json(response.body) unless response.success?
        API::Result(Nil).new(result)
      end
    end
  end
end
