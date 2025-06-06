require "json"
require "./shift_break"
require "./converters/time"

module TandaCLI
  module Types
    class Shift
      include JSON::Serializable
      include Utils::Mixins::PrettyTimes

      # defaults
      @leave_request : Types::LeaveRequest? = nil
      @leave_request_set : Bool = false
      @valid_breaks : Array(ShiftBreak)? = nil

      enum Status
        Pending
        Approved
        Exported
      end

      module StatusConverter
        def self.from_json(value : JSON::PullParser) : Status
          status_string = value.read_string
          Status.parse?(status_string) || raise("Unknown status: #{status_string}")
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
        client : API::Client,
      ) : Array(Types::Shift) | Types::Error
        leave_request_ids = shifts.compact_map(&.leave_request_id)
        return shifts if leave_request_ids.empty?

        leave_requests_by_id = client.leave_requests(ids: leave_request_ids).or { |error| return error }.index_by(&.id)

        if leave_requests_by_id.present?
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

      @[JSON::Field(key: "date", converter: TandaCLI::Types::Converters::Time::FromISODate)]
      getter date : Time

      @[JSON::Field(key: "start", converter: TandaCLI::Types::Converters::Time::FromMaybeUnix)]
      getter start_time : Time?

      @[JSON::Field(key: "finish", converter: TandaCLI::Types::Converters::Time::FromMaybeUnix)]
      getter finish_time : Time?

      @[JSON::Field(key: "status", converter: TandaCLI::Types::Shift::StatusConverter)]
      getter status : Status

      getter leave_request : Types::LeaveRequest?

      @[JSON::Field(key: "notes")]
      getter _nilable_notes : Array(Types::Note)?

      def day_of_week : Time::DayOfWeek
        date.day_of_week
      end

      def notes : Array(Types::Note)
        _nilable_notes || Array(Types::Note).new
      end

      def set_leave_request!(leave_request : Types::LeaveRequest)
        raise("Leave request already set!") if @leave_request_set
        raise("Leave request doesn't belong to shift!") if leave_request.id != leave_request_id

        @leave_request_set = true
        @leave_request = leave_request
      end

      def valid_breaks : Array(ShiftBreak)
        @valid_breaks ||= breaks.select(&.valid?)
      end

      def ongoing? : Bool
        return false unless start_time

        finish_time.nil?
      end

      def ongoing_break? : Bool
        valid_breaks.any?(&.ongoing?)
      end

      def ongoing_without_break? : Bool
        ongoing? && valid_breaks.empty?
      end

      def time_worked(treat_paid_breaks_as_unpaid : Bool) : Time::Span?
        start_time = self.start_time
        return if start_time.nil?

        finish_time = self.finish_time
        return if finish_time.nil?

        (finish_time - start_time) - total_unpaid_break_minutes(treat_paid_breaks_as_unpaid)
      end

      def worked_so_far(treat_paid_breaks_as_unpaid : Bool) : Time::Span?
        start_time = self.start_time
        return if start_time.nil?

        now = Utils::Time.now
        return if now.date != start_time.date

        (now - start_time) - total_unpaid_break_minutes(treat_paid_breaks_as_unpaid)
      end

      def visible? : Bool
        !!(start_time || finish_time) || leave?
      end

      private def leave? : Bool
        !!leave_request_id
      end

      private def total_unpaid_break_minutes(treat_paid_breaks_as_unpaid : Bool) : Time::Span
        (treat_paid_breaks_as_unpaid ? valid_breaks : valid_breaks.reject(&.paid?)).sum(&.ongoing_length).minutes
      end
    end
  end
end
