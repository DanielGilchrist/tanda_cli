require "json"
require "./converters/span"
require "./converters/time"

module TandaCLI
  module Types
    class LeaveRequest
      include JSON::Serializable

      enum Status
        Pending
        Approved
        Rejected
      end

      module StatusConverter
        def self.from_json(value : JSON::PullParser) : Status
          status_string = value.read_string
          Status.parse?(status_string) || raise("Unknown status: #{status_string}")
        end
      end

      getter id : Int32
      getter user_id : Int32
      getter leave_type : String
      getter reason : String?

      @[JSON::Field(key: "status", converter: TandaCLI::Types::LeaveRequest::StatusConverter)]
      getter status : Status

      @[JSON::Field(key: "daily_breakdown")]
      getter daily_breakdown : Array(Types::LeaveRequest::DailyBreakdown)

      def breakdown_for(shift : Types::Shift) : Types::LeaveRequest::DailyBreakdown?
        daily_breakdown.find(&.shift_id.==(shift.id))
      end
    end
  end
end
