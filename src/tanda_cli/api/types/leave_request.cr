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

        module Status
          alias Any = Known | Unknown

          enum Known
            Pending
            Approved
            Rejected
          end

          struct Unknown
            def initialize(@raw : String); end

            getter raw : String

            def to_s(io : IO) : Nil
              io << raw
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
        getter leave_type : String
        getter reason : String?
        getter daily_breakdown : Array(DailyBreakdown)

        @[JSON::Field(key: "status", converter: TandaCLI::API::Types::LeaveRequest::StatusConverter)]
        getter status : Status::Any

        def each(& : DailyBreakdown ->) : Nil
          daily_breakdown.each { |breakdown| yield breakdown }
        end
      end
    end
  end
end
