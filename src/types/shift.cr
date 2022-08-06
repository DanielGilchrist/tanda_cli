require "json"
require "./shift_break"
require "./converters/time"

module Tanda::CLI
  class Types::Shift
    include JSON::Serializable

    enum Status
      Pending
      Approved
      Exported
    end

    module StatusConverter
      def self.from_json(value : JSON::PullParser) : Status
        status_string = value.read_string
        case status_string
        when "PENDING"
          Status::Pending
        when "APPROVED"
          Status::Approved
        when "EXPORTED"
          Status::Exported
        else
          raise "Unknown status: #{status_string}"
        end
      end
    end

    @[JSON::Field(key: "id")]
    property id : Int32

    @[JSON::Field(key: "user_id")]
    property user_id : Int32

    @[JSON::Field(key: "start", converter: Tanda::CLI::Types::Converters::Time)]
    property start : Time?

    @[JSON::Field(key: "finish", converter: Tanda::CLI::Types::Converters::Time)]
    property finish : Time?

    @[JSON::Field(key: "status", converter: Tanda::CLI::Types::Shift::StatusConverter)]
    property status : Status

    @[JSON::Field(key: "breaks")]
    property breaks : Array(ShiftBreak)

    @[JSON::Field(key: "leave_request_id")]
    property leave_request_id : Int32?

    def time_worked : Time::Span?
      s = start
      return if s.nil?

      f = finish
      return if f.nil?

      (f - s) - total_break_minutes
    end

    def worked_so_far : Time::Span?
      s = start
      return if s.nil?

      now = Time.local(Time::Location.load("Europe/London"))
      return unless now.date == s.date

      (now - s) - total_break_minutes
    end

    def total_break_minutes : Time::Span
      breaks.sum(&.length).minutes
    end
  end
end
