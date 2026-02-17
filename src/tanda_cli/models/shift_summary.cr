require "./shift_summary/*"

module TandaCLI
  module Models
    struct ShiftSummary
      alias RegularHoursSchedule = Configuration::Serialisable::Organisation::RegularHoursSchedule

      include Enumerable(ClassifiedShift)

      @classified_shifts : Array(ClassifiedShift)

      def initialize(
        shifts : Array(Types::Shift),
        treat_paid_breaks_as_unpaid : Bool = false,
        @regular_hours_schedules : Array(RegularHoursSchedule)? = nil,
      )
        @classified_shifts = classify(shifts, treat_paid_breaks_as_unpaid)
      end

      def each(& : ClassifiedShift ->) : Nil
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
        worked_shifts.sum(&.time_worked)
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

        shifts = @classified_shifts.map(&.shift)
        shifts_by_day_of_week = shifts.group_by(&.day_of_week)

        applicable_regular_hours_schedules = regular_hours_schedules.select do |schedule|
          shifts_by_day_of_week.has_key?(schedule.day_of_week)
        end
        return if applicable_regular_hours_schedules.empty?

        applicable_regular_hours_schedules.sum do |regular_hours_schedule|
          day_shifts = shifts_by_day_of_week[regular_hours_schedule.day_of_week]?
          if day_shifts && day_shifts.any?(&.ongoing_without_break?) && !breaks_already_taken?(regular_hours_schedule, day_shifts)
            regular_hours_schedule.length
          else
            regular_hours_schedule.worked_length
          end
        end - worked_time - leave_time
      end

      private def classify(shifts : Array(Types::Shift), treat_paid_breaks_as_unpaid : Bool) : Array(ClassifiedShift)
        shifts.map do |shift|
          LeaveShift.from?(shift) ||
            WorkedShift.from(shift, treat_paid_breaks_as_unpaid, @regular_hours_schedules)
        end
      end

      private def breaks_already_taken?(
        regular_hours_schedule : RegularHoursSchedule,
        shifts : Array(Types::Shift),
      ) : Bool
        expected_break_count =
          if regular_hours_schedule.breaks.present?
            regular_hours_schedule.breaks.size
          elsif (automatic_break_length = regular_hours_schedule.automatic_break_length) && automatic_break_length > 0
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
