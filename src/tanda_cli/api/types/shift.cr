require "json"
require "./shift_break"
require "./converters/time"

module TandaCLI
  module API
    module Types
      struct Shift
        include JSON::Serializable

        enum Status
          Pending
          Approved
          Exported
        end

        module StatusConverter
          def self.from_json(value : JSON::PullParser) : Status
            status_string = value.read_string
            Status.parse?(status_string) || raise("Unknown status: #{status_string}")
          end
        end

        getter id : Int32
        getter user_id : Int32
        getter breaks : Array(ShiftBreak)
        getter leave_request_id : Int32?

        @[JSON::Field(key: "date", converter: TandaCLI::API::Types::Converters::Time::FromISODate)]
        getter date : Time

        @[JSON::Field(key: "start", converter: TandaCLI::API::Types::Converters::Time::FromMaybeUnix)]
        getter start_time : Time?

        @[JSON::Field(key: "finish", converter: TandaCLI::API::Types::Converters::Time::FromMaybeUnix)]
        getter finish_time : Time?

        @[JSON::Field(key: "status", converter: TandaCLI::API::Types::Shift::StatusConverter)]
        getter status : Status

        @[JSON::Field(key: "notes")]
        getter _nilable_notes : Array(API::Types::Note)?
      end
    end
  end
end
