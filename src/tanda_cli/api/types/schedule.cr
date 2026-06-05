require "json"
require "./converters/span"
require "./converters/time"

module TandaCLI
  module API
    module Types
      struct Schedule
        include JSON::Serializable

        struct Break
          include JSON::Serializable

          @[JSON::Field(key: "start", converter: TandaCLI::API::Types::Converters::Time::FromMaybeUnix)]
          getter start_time : Time?

          @[JSON::Field(key: "finish", converter: TandaCLI::API::Types::Converters::Time::FromMaybeUnix)]
          getter finish_time : Time?
        end

        @[JSON::Field(key: "start", converter: TandaCLI::API::Types::Converters::Time::FromMaybeUnix)]
        getter start_time : Time?

        @[JSON::Field(key: "finish", converter: TandaCLI::API::Types::Converters::Time::FromMaybeUnix)]
        getter finish_time : Time?

        @[JSON::Field(converter: TandaCLI::API::Types::Converters::Span::FromMinutes)]
        getter automatic_break_length : Time::Span
        getter breaks : Array(Schedule::Break)
        getter user_id : Int32?
      end
    end
  end
end
