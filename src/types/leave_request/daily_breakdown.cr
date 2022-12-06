require "json"
require "../converters/span"
require "../converters/time"

module Tanda::CLI
  module Types
    class LeaveRequest
      class DailyBreakdown
        include JSON::Serializable
        include Utils::Mixins::PrettyTimes

        module StringIDConverter
          def self.from_json(value : JSON::PullParser) : Int32
            value.read_string.to_i32
          end
        end

        @[JSON::Field(key: "id", converter: Tanda::CLI::Types::LeaveRequest::DailyBreakdown::StringIDConverter)]
        getter shift_id : Int32

        @[JSON::Field(key: "date", converter: Tanda::CLI::Types::Converters::Time::FromISODate)]
        getter date : Time

        @[JSON::Field(key: "start_time", converter: Tanda::CLI::Types::Converters::Time::FromMaybeUnix)]
        getter start_time : Time?

        @[JSON::Field(key: "finish_time", converter: Tanda::CLI::Types::Converters::Time::FromMaybeUnix)]
        getter finish_time : Time?

        @[JSON::Field(key: "hours", converter: Tanda::CLI::Types::Converters::Span::FromHoursFloat)]
        getter hours : Time::Span
      end
    end
  end
end
