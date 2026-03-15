require "json"
require "./converters/span"
require "./converters/time"

module TandaCLI
  module Types
    struct LeaveRequest
      include JSON::Serializable
      include Enumerable(DailyBreakdown)

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
      getter daily_breakdown : Array(DailyBreakdown)

      @[JSON::Field(key: "status", converter: TandaCLI::Types::LeaveRequest::StatusConverter)]
      getter status : Status

      def each(& : DailyBreakdown ->) : Nil
        daily_breakdown.each { |breakdown| yield breakdown }
      end
    end
  end
end
