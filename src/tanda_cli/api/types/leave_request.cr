require "json"
require "./converters/span"
require "./converters/time"
require "./leave_request/daily_breakdown"

module TandaCLI
  module API
    module Types
      struct LeaveRequest
        include JSON::Serializable
        include Enumerable(DailyBreakdown)

        enum Status
          Pending
          Approved
          Rejected
          Unknown
        end

        module StatusConverter
          def self.from_json(value : JSON::PullParser) : Status
            Status.parse?(value.read_string) || Status::Unknown
          end
        end

        getter id : Int32
        getter user_id : Int32
        getter leave_type : String
        getter reason : String?
        getter daily_breakdown : Array(DailyBreakdown)

        @[JSON::Field(key: "status", converter: TandaCLI::API::Types::LeaveRequest::StatusConverter)]
        getter status : Status

        def each(& : DailyBreakdown ->) : Nil
          daily_breakdown.each { |breakdown| yield breakdown }
        end
      end
    end
  end
end
