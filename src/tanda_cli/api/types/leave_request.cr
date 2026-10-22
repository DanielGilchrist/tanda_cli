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
            def initialize(@value : String) : Nil; end

            getter value : String

            def to_s(io : IO) : Nil
              io << value
            end
          end
        end

        module StatusConverter
          extend self

          def from_json(value : JSON::PullParser) : Status::Any
            raw = value.read_string
            Status::Known.parse?(raw) || Status::Unknown.new(raw)
          end
        end

        getter id : Int32
        getter user_id : Int32
        getter leave_type : String
        getter reason : String?
        getter daily_breakdown : Array(DailyBreakdown)
        getter? all_day : Bool = false

        @[JSON::Field(key: "start", converter: TandaCLI::API::Types::Converters::Time::FromISODate)]
        getter start : Time

        @[JSON::Field(key: "finish", converter: TandaCLI::API::Types::Converters::Time::FromISODate)]
        getter finish : Time

        @[JSON::Field(key: "hours", converter: TandaCLI::API::Types::Converters::Span::FromHoursFloat)]
        getter hours : Time::Span

        @[JSON::Field(key: "status", converter: TandaCLI::API::Types::LeaveRequest::StatusConverter)]
        getter status : Status::Any

        def each(& : DailyBreakdown ->) : Nil
          daily_breakdown.each { |breakdown| yield breakdown }
        end

        def single_day? : Bool
          start == finish
        end

        def public_holiday? : Bool
          !daily_breakdown.empty? && daily_breakdown.all?(&.holiday?)
        end

        def days : Int32
          (finish - start).total_days.round.to_i + 1
        end
      end
    end
  end
end
