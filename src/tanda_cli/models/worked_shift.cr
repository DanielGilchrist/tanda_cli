require "../utils/mixins/pretty_times"
require "./shift_break"

module TandaCLI
  module Models
    struct WorkedShift
      include Utils::Mixins::PrettyTimes

      def self.from?(
        api_shift : API::Types::Shift,
        treat_paid_breaks_as_unpaid : Bool = false,
        regular_hours_schedules : Array(RegularHoursSchedule)? = nil,
      ) : WorkedShift?
        return if api_shift.leave_request_id
        return if api_shift.start_time.nil? && api_shift.finish_time.nil?

        new(api_shift, treat_paid_breaks_as_unpaid, regular_hours_schedules)
      end

      def initialize(
        @api_shift : API::Types::Shift,
        @treat_paid_breaks_as_unpaid : Bool = false,
        @regular_hours_schedules : Array(RegularHoursSchedule)? = nil,
      )
        @breaks = @api_shift.breaks.map { |api_break| ShiftBreak.new(api_break) }
      end

      delegate :id, :user_id, :date, :status, :start_time, :finish_time, to: @api_shift

      getter breaks : Array(ShiftBreak)

      def day_of_week : Time::DayOfWeek
        date.day_of_week
      end

      def notes : Array(API::Types::Note)
        @api_shift._nilable_notes || Array(API::Types::Note).new
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

      def time_worked : Time::Span
        resolved_time_worked || Time::Span.zero
      end

      def assumed_finish? : Bool
        !expected_finish_time.nil?
      end

      def expected_finish_time : Time?
        matching_schedule.try(&.finish_time)
      end

      def expected_break_length : Time::Span?
        matching_schedule.try(&.break_length)
      end

      def shift_representer : Representers::Shift
        Representers::Shift.new(self, expected_finish_time, expected_break_length)
      end

      @valid_breaks : Array(ShiftBreak)? = nil

      private def resolved_time_worked : Time::Span?
        raw_time_worked || expected_time_worked || raw_worked_so_far
      end

      private def raw_time_worked : Time::Span?
        start_time = self.start_time
        return if start_time.nil?

        finish_time = self.finish_time
        return if finish_time.nil?

        (finish_time - start_time) - total_unpaid_break_minutes
      end

      private def raw_worked_so_far : Time::Span?
        start_time = self.start_time
        return if start_time.nil?

        now = Utils::Time.now
        return if now.date != start_time.date

        (now - start_time) - total_unpaid_break_minutes
      end

      private def expected_time_worked : Time::Span?
        schedule = matching_schedule
        return unless schedule

        calculate_expected_time_worked(schedule)
      end

      private def matching_schedule : RegularHoursSchedule?
        return if raw_time_worked
        return if finish_time

        schedules = @regular_hours_schedules
        return unless schedules
        return if date.date == Utils::Time.now.date

        schedules.find(&.day_of_week.==(day_of_week))
      end

      private def calculate_expected_time_worked(schedule : RegularHoursSchedule) : Time::Span?
        start_time = self.start_time
        return unless start_time

        expected_finish = Time.local(
          date.year,
          date.month,
          date.day,
          schedule.finish_time.hour,
          schedule.finish_time.minute,
          location: Utils::Time.location
        )

        actual_break_time = (@treat_paid_breaks_as_unpaid ? valid_breaks : valid_breaks.reject(&.paid?)).sum(&.ongoing_length).minutes
        expected_break_time = actual_break_time == 0.minutes ? schedule.break_length : 0.minutes
        total_break_time = actual_break_time + expected_break_time

        (expected_finish - start_time) - total_break_time
      end

      private def total_unpaid_break_minutes : Time::Span
        (@treat_paid_breaks_as_unpaid ? valid_breaks : valid_breaks.reject(&.paid?)).sum(&.ongoing_length).minutes
      end
    end
  end
end
