require "json"

require "./interface.cr"
require "../client"

module Tanda::CLI
  module API
    module Endpoints::ClockIn
      include Endpoints::Interface

      def send_clockin(time : Time, type : String) : Types::Error?
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
