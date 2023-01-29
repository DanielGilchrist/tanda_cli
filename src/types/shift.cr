require "json"
require "./shift_break"
require "./converters/time"

module Tanda::CLI
  module Types
    class Shift
      include JSON::Serializable
      include Utils::Mixins::PrettyTimes

      # defaults
      @leave_request : Types::LeaveRequest? = nil
      @leave_request_set : Bool = false

      enum Status
        Pending
        Approved
        Exported
      end

      module StatusConverter
        def self.from_json(value : JSON::PullParser) : Status
          status_string = value.read_string
          Status.parse?(status_string) || Utils::Display.fatal!("Unknown status: #{status_string}")
        end
      end

      # Parse shifts and any associated leave requests
      def self.from_array(response : HTTP::Client::Response, client : API::Client) : API::Result(Array(self))
        API::Result(Array(self)).from(response) do |shifts|
          fetch_and_attach_leave_requests(shifts, client)
        end
      end

      private def self.fetch_and_attach_leave_requests(
        shifts : Array(Types::Shift),
        client : API::Client
      ) : Array(Types::Shift) | Types::Error
        leave_request_ids = shifts.compact_map(&.leave_request_id)
        return shifts if leave_request_ids.empty?

        leave_requests_by_id = client.leave_requests(ids: leave_request_ids).or { |error| return error }.index_by(&.id)

        if !leave_requests_by_id.empty?
          shifts.each do |shift|
            leave_request_id = shift.leave_request_id
            next if leave_request_id.nil?

            leave_request = leave_requests_by_id[leave_request_id]?
            next if leave_request.nil?

            shift.set_leave_request!(leave_request)
          end
        end

        shifts
      end

      getter id : Int32
      getter user_id : Int32
      getter breaks : Array(ShiftBreak)
      getter leave_request_id : Int32?

      @[JSON::Field(key: "date", converter: Tanda::CLI::Types::Converters::Time::FromISODate)]
      getter date : Time

      @[JSON::Field(key: "start", converter: Tanda::CLI::Types::Converters::Time::FromMaybeUnix)]
      getter start_time : Time?

      @[JSON::Field(key: "finish", converter: Tanda::CLI::Types::Converters::Time::FromMaybeUnix)]
      getter finish_time : Time?

      @[JSON::Field(key: "status", converter: Tanda::CLI::Types::Shift::StatusConverter)]
      getter status : Status

      getter leave_request : Types::LeaveRequest?

      def set_leave_request!(leave_request : Types::LeaveRequest)
        Utils::Display.fatal!("Leave request already set!") if @leave_request_set
        Utils::Display.fatal!("Leave request doesn't belong to shift!") if leave_request.id != leave_request_id

        @leave_request_set = true
        @leave_request = leave_request
      end

      def time_worked : Time::Span?
        start_time = self.start_time
        return if start_time.nil?

        finish_time = self.finish_time
        return if finish_time.nil?

        (finish_time - start_time) - total_break_minutes
      end

      def worked_so_far : Time::Span?
        start_time = self.start_time
        return if start_time.nil?

        now = Utils::Time.now
        return unless now.date == start_time.date

        (now - start_time) - total_break_minutes
      end

      private def total_break_minutes : Time::Span
        breaks.sum(&.ongoing_length).minutes
      end
    end
  end
end
