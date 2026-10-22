require "json"
require "../../../utils/mixins/pretty_times"

require "../converters/span"
require "../converters/time"

module TandaCLI
  module API
    module Types
      struct LeaveRequest
        struct DailyBreakdown
          include JSON::Serializable
          include Utils::Mixins::PrettyTimes

          getter id : String

          @[JSON::Field(key: "date", converter: TandaCLI::API::Types::Converters::Time::FromISODate)]
          getter date : Time

          @[JSON::Field(key: "start_time", converter: TandaCLI::API::Types::Converters::Time::FromMaybeUnix)]
          getter start_time : Time?

          @[JSON::Field(key: "finish_time", converter: TandaCLI::API::Types::Converters::Time::FromMaybeUnix)]
          getter finish_time : Time?

          @[JSON::Field(key: "hours", converter: TandaCLI::API::Types::Converters::Span::FromHoursFloat)]
          getter hours : Time::Span

          @[JSON::Field(key: "is_holiday")]
          getter? holiday : Bool = false

          def shift_id : Int32?
            @id.to_i32?
          end
        end
      end
    end
  end
end
