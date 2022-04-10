require "json"

module Tanda::CLI
  class Types::Shift
    include JSON::Serializable

    enum Status
      Pending
      Approved
      Exported
    end

    module StatusConverter
      def self.from_json(value : JSON::PullParser) : Status
        status_string = value.read_string
        case status_string
        when "PENDING"
          Status::Pending
        when "APPROVED"
          Status::Approved
        when "EXPORTED"
          Status::Exported
        else
          raise "Unknown status: #{status_string}"
        end
      end
    end

    module TimeConverter
      def self.from_json(value : JSON::PullParser) : Time
        time = Time.unix(value.read_int)
        time.in(Time::Location.load("Europe/London")) # TODO: Don't hard-code time zone
      end
    end

    @[JSON::Field(key: "id")]
    property id : Int32

    @[JSON::Field(key: "user_id")]
    property user_id : Int32

    @[JSON::Field(key: "start", converter: Tanda::CLI::Types::Shift::TimeConverter)]
    property start : Time?

    @[JSON::Field(key: "finish", converter: Tanda::CLI::Types::Shift::TimeConverter)]
    property finish : Time?

    @[JSON::Field(key: "status", converter: Tanda::CLI::Types::Shift::StatusConverter)]
    property status : Status
  end
end
