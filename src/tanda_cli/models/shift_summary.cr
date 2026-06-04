require "./shift"

module TandaCLI
  module Models
    struct ShiftSummary
      include Enumerable(Shift::Any)

      def self.from_api(
        api_shifts : Array(API::Types::Shift),
        leave_requests : Array(API::Types::LeaveRequest) = Array(API::Types::LeaveRequest).new,
        treat_paid_breaks_as_unpaid : Bool = false,
        regular_hours_schedules : Array(RegularHoursSchedule)? = nil,
      ) : self
        leave_requests_by_id = leave_requests.index_by(&.id)

        classified = api_shifts.compact_map do |api_shift|
          Shift.parse?(api_shift, leave_requests_by_id)
        end

        new(classified, treat_paid_breaks_as_unpaid, regular_hours_schedules)
      end

      def initialize(
        @classified_shifts : Array(Shift::Any),
        @treat_paid_breaks_as_unpaid : Bool = false,
        @regular_hours_schedules : Array(RegularHoursSchedule)? = nil,
      ); end

      def each(& : Shift::Any ->) : Nil
        @classified_shifts.each { |shift| yield shift }
      end

      def representer : Representers::ShiftSummary
        Representers::ShiftSummary.new(self)
      end

      def worked_shifts : Array(WorkedShift)
        compact_map(&.as?(WorkedShift))
      end

      def leave_shifts : Array(LeaveShift)
        compact_map(&.as?(LeaveShift))
      end

      def worked_time : Time::Span
        worked_shifts.sum { |shift| time_worked_for(shift) }
      end

      def leave_time : Time::Span
        leave_shifts.sum(&.leave_taken)
      end

      def empty? : Bool
        worked_time.zero? && leave_time.zero?
      end

      def any_ongoing? : Bool
        worked_shifts.any?(&.ongoing?)
      end

      def time_left : Time::Span?
        regular_hours_schedules = @regular_hours_schedules
        return if regular_hours_schedules.nil? || regular_hours_schedules.empty?

        days_with_shifts = @classified_shifts.to_set(&.day_of_week)
        worked_by_day_of_week = worked_shifts.group_by(&.day_of_week)

        applicable_regular_hours_schedules = regular_hours_schedules.select do |schedule|
          days_with_shifts.includes?(schedule.day_of_week)
        end
        return if applicable_regular_hours_schedules.empty?

        applicable_regular_hours_schedules.sum do |regular_hours_schedule|
          day_shifts = worked_by_day_of_week[regular_hours_schedule.day_of_week]?
          if day_shifts && day_shifts.any?(&.ongoing_without_break?) && !breaks_already_taken?(regular_hours_schedule, day_shifts)
            regular_hours_schedule.length
          else
            regular_hours_schedule.worked_length
          end
        end - worked_time - leave_time
      end

      def time_worked_for(shift : WorkedShift) : Time::Span
        raw_time_worked(shift) || expected_time_worked(shift) || worked_so_far(shift) || Time::Span.zero
      end

      def expected_finish_time_for(shift : WorkedShift) : Time?
        matching_schedule_for(shift).try(&.finish_time)
      end

      def expected_break_length_for(shift : WorkedShift) : Time::Span?
        matching_schedule_for(shift).try(&.break_length)
      end

      def assumed_finish_for?(shift : WorkedShift) : Bool
        !expected_finish_time_for(shift).nil?
      end

      def shift_representer_for(shift : WorkedShift) : Representers::Shift
        Representers::Shift.new(shift, expected_finish_time_for(shift), expected_break_length_for(shift))
      end

      private def raw_time_worked(shift : WorkedShift) : Time::Span?
        start_time = shift.start_time
        return if start_time.nil?

        finish_time = shift.finish_time
        return if finish_time.nil?

        (finish_time - start_time) - total_unpaid_break_minutes(shift)
      end

      private def worked_so_far(shift : WorkedShift) : Time::Span?
        start_time = shift.start_time
        return if start_time.nil?

        now = Utils::Time.now
        return if now.date != start_time.date

        (now - start_time) - total_unpaid_break_minutes(shift)
      end

      private def expected_time_worked(shift : WorkedShift) : Time::Span?
        schedule = matching_schedule_for(shift)
        return unless schedule

        calculate_expected_time_worked(shift, schedule)
      end

      private def matching_schedule_for(shift : WorkedShift) : RegularHoursSchedule?
        return if raw_time_worked(shift)
        return if shift.finish_time

        schedules = @regular_hours_schedules
        return unless schedules
        return if shift.date.date == Utils::Time.now.date

        schedules.find(&.day_of_week.==(shift.day_of_week))
      end

      private def calculate_expected_time_worked(shift : WorkedShift, schedule : RegularHoursSchedule) : Time::Span?
        start_time = shift.start_time
        return unless start_time

        expected_finish = Time.local(
          shift.date.year,
          shift.date.month,
          shift.date.day,
          schedule.finish_time.hour,
          schedule.finish_time.minute,
          location: Utils::Time.location
        )

        actual_break_time = breaks_for_calculation(shift).sum(&.ongoing_length).minutes
        expected_break_time = actual_break_time == 0.minutes ? schedule.break_length : 0.minutes
        total_break_time = actual_break_time + expected_break_time

        (expected_finish - start_time) - total_break_time
      end

      private def total_unpaid_break_minutes(shift : WorkedShift) : Time::Span
        breaks_for_calculation(shift).sum(&.ongoing_length).minutes
      end

      private def breaks_for_calculation(shift : WorkedShift) : Array(ShiftBreak)
        @treat_paid_breaks_as_unpaid ? shift.valid_breaks : shift.valid_breaks.reject(&.paid?)
      end

      private def breaks_already_taken?(
        regular_hours_schedule : RegularHoursSchedule,
        shifts : Array(WorkedShift),
      ) : Bool
        expected_break_count =
          if regular_hours_schedule.breaks.present?
            regular_hours_schedule.breaks.size
          elsif regular_hours_schedule.automatic_break_length > 0
            1
          else
            0
          end

        return false if expected_break_count.zero?

        taken_break_count = shifts.sum(&.valid_breaks.size)
        taken_break_count >= expected_break_count
      end
    end
  end
end
