require "json"
require "./shift_break"
require "./converters/time"

module Tanda::CLI
  class Types::Shift
    include JSON::Serializable

    DEFAULT_DATE_FORMAT = "%A, %d %b %Y"

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
    getter id : Int32

    @[JSON::Field(key: "user_id")]
    getter user_id : Int32

    @[JSON::Field(key: "date", converter: Tanda::CLI::Types::Converters::Time::FromISODate)]
    getter date : Time

    @[JSON::Field(key: "start", converter: Tanda::CLI::Types::Converters::Time::FromMaybeUnix)]
    getter start : Time?

    @[JSON::Field(key: "finish", converter: Tanda::CLI::Types::Converters::Time::FromMaybeUnix)]
    getter finish : Time?

    @[JSON::Field(key: "status", converter: Tanda::CLI::Types::Shift::StatusConverter)]
    getter status : Status

    @[JSON::Field(key: "breaks")]
    getter breaks : Array(ShiftBreak)

    def pretty_date : String
      Time::Format.new(DEFAULT_DATE_FORMAT).format(date)
    end

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
