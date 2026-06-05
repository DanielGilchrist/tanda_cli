require "json"
require "./converters/span"
require "./converters/time"

module TandaCLI
  module API
    module Types
      struct ShiftBreak
        include JSON::Serializable

        getter id : Int32
        getter shift_id : Int32

        @[JSON::Field(converter: TandaCLI::API::Types::Converters::Span::FromMinutes)]
        getter length : Time::Span

        getter? paid : Bool

        @[JSON::Field(key: "start", converter: TandaCLI::API::Types::Converters::Time::FromMaybeUnix)]
        getter start_time : Time?

        @[JSON::Field(key: "finish", converter: TandaCLI::API::Types::Converters::Time::FromMaybeUnix)]
        getter finish_time : Time?
      end
    end
  end
end
