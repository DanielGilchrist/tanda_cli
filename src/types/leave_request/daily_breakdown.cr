require "json"
require "../converters/span"
require "../converters/time"

module Tanda::CLI
  module Types
    class LeaveRequest
      class DailyBreakdown
        include JSON::Serializable
        include Utils::Mixins::PrettyStartFinish

        module StringIDConverter
          def self.from_json(value : JSON::PullParser) : Int32
            value.read_string.to_i32
          end
        end

        # {
        #   "id": "374673344",
        #   "date": "2022-12-01",
        #   "all_day": true,
        #   "department_id": "3543532",
        #   "start_time": null,
        #   "finish_time": null,
        #   "hours": 8.0,
        #   "is_holiday": false,
        #   "times": {},
        #   "timesheet_on_this_day_is_exported": false,
        #   "filled_from": "other"
        # }

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

        def pretty_date : String
          Utils::Time.pretty_date(date)
        end
      end
    end
  end
end
