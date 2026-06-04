require "json"
require "../converters/span"
require "../converters/time"

module TandaCLI
  module API
    module Types
      struct LeaveRequest
        struct DailyBreakdown
          include JSON::Serializable
          include Utils::Mixins::PrettyTimes

          module StringIDConverter
            def self.from_json(value : JSON::PullParser) : Int32
              value.read_string.to_i32
            end
          end

          @[JSON::Field(key: "id", converter: TandaCLI::API::Types::LeaveRequest::DailyBreakdown::StringIDConverter)]
          getter shift_id : Int32

          @[JSON::Field(key: "date", converter: TandaCLI::API::Types::Converters::Time::FromISODate)]
          getter date : Time

          @[JSON::Field(key: "start_time", converter: TandaCLI::API::Types::Converters::Time::FromMaybeUnix)]
          getter start_time : Time?

          @[JSON::Field(key: "finish_time", converter: TandaCLI::API::Types::Converters::Time::FromMaybeUnix)]
          getter finish_time : Time?

          @[JSON::Field(key: "hours", converter: TandaCLI::API::Types::Converters::Span::FromHoursFloat)]
          getter hours : Time::Span
        end
      end
    end
  end
end
