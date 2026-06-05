require "json"
require "./shift_break"
require "./converters/time"

module TandaCLI
  module API
    module Types
      struct Shift
        include JSON::Serializable

        module Status
          alias Any = Known | Unknown

          enum Known
            Pending
            Approved
            Exported
          end

          struct Unknown
            def initialize(@value : String); end

            getter value : String

            def to_s(io : IO) : Nil
              io << value
            end
          end
        end

        module StatusConverter
          def self.from_json(value : JSON::PullParser) : Status::Any
            raw = value.read_string
            Status::Known.parse?(raw) || Status::Unknown.new(raw)
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
        getter status : Status::Any

        @[JSON::Field(key: "notes")]
        private getter _nilable_notes : Array(API::Types::Note)?

        def notes : Array(API::Types::Note)
          _nilable_notes || Array(API::Types::Note).new
        end
      end
    end
  end
end
