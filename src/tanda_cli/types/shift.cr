require "json"
require "./shift_break"
require "./converters/time"

module TandaCLI
  module Types
    struct Shift
      include JSON::Serializable
      include Utils::Mixins::PrettyTimes

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

      @[JSON::Field(key: "notes")]
      getter _nilable_notes : Array(Types::Note)?

      def day_of_week : Time::DayOfWeek
        date.day_of_week
      end

      def notes : Array(Types::Note)
        _nilable_notes || Array(Types::Note).new
      end

      def valid_breaks : Array(ShiftBreak)
        @valid_breaks ||= breaks.select(&.valid?)
      end

      def ongoing? : Bool
        return false unless start_time
        return false unless finish_time.nil?

        date.date == Utils::Time.now.date
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

      def leave? : Bool
        !!leave_request_id
      end

      private def total_unpaid_break_minutes(treat_paid_breaks_as_unpaid : Bool) : Time::Span
        (treat_paid_breaks_as_unpaid ? valid_breaks : valid_breaks.reject(&.paid?)).sum(&.ongoing_length).minutes
      end
    end
  end
end
