require "json"
require "./converters/span"
require "./converters/time"

module Tanda::CLI
  module Types
    class LeaveRequest
      include JSON::Serializable

      DEFAULT_DATE_FORMAT = "%A, %d %b %Y"

      enum Status
        Pending
        Approved
        Rejected
      end

      module StatusConverter
        def self.from_json(value : JSON::PullParser) : Status
          status_string = value.read_string
          Status.parse?(status_string) || raise "Unknown status: #{status_string}"
        end
      end

      @[JSON::Field(key: "id")]
      getter id : Int32

      @[JSON::Field(key: "user_id")]
      getter user_id : Int32

      @[JSON::Field(key: "hours", converter: Tanda::CLI::Types::Converters::Span::FromHoursFloat)]
      getter hours : Time::Span

      @[JSON::Field(key: "start", converter: Tanda::CLI::Types::Converters::Time::FromISODate)]
      getter start : Time

      @[JSON::Field(key: "finish", converter: Tanda::CLI::Types::Converters::Time::FromISODate)]
      getter finish : Time

      @[JSON::Field(key: "status", converter: Tanda::CLI::Types::LeaveRequest::StatusConverter)]
      getter status : Status

      def pretty_dates : Tuple(String, String)
        { start, finish }.map { |date| Time::Format.new(DEFAULT_DATE_FORMAT).format(date) }
      end
    end
  end
end
