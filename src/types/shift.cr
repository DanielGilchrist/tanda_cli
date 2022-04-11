require "json"
require "./shift_break"

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

    # TODO: Refactor out
    module TimeConverter
      def self.from_json(value : JSON::PullParser) : Time
        time = Time.unix(value.read_int)
        time.in(Time::Location.load("Europe/London")) # TODO: Don't hard-code time zone
      end
    end

    @[JSON::Field(key: "id")]
    property id : Int32

    @[JSON::Field(key: "user_id")]
    property user_id : Int32

    @[JSON::Field(key: "start", converter: Tanda::CLI::Types::Shift::TimeConverter)]
    property start : Time?

    @[JSON::Field(key: "finish", converter: Tanda::CLI::Types::Shift::TimeConverter)]
    property finish : Time?

    @[JSON::Field(key: "status", converter: Tanda::CLI::Types::Shift::StatusConverter)]
    property status : Status

    @[JSON::Field(key: "breaks")]
    property breaks : Array(ShiftBreak)

    def time_worked : Time::Span?
      s = start
      return if s.nil?

      f = finish
      return if f.nil?

      f - s
    end

    def worked_so_far : Time::Span?
      s = start
      return if s.nil?

      now = Time.local(Time::Location.load("Europe/London"))
      return unless now.date == s.date

      (now - s) - breaks.sum(&.length).minutes
    end
  end
end
