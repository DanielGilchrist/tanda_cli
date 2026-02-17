module TandaCLI
  module Models
    struct ShiftSummary
      struct WorkedShift
        alias RegularHoursSchedule = Configuration::Serialisable::Organisation::RegularHoursSchedule

        def self.from(
          shift : Types::Shift,
          treat_paid_breaks_as_unpaid : Bool = false,
          regular_hours_schedules : Array(RegularHoursSchedule)? = nil,
        ) : WorkedShift
          new(shift, treat_paid_breaks_as_unpaid, regular_hours_schedules)
        end

        def initialize(
          @shift : Types::Shift,
          @treat_paid_breaks_as_unpaid : Bool = false,
          @regular_hours_schedules : Array(RegularHoursSchedule)? = nil,
        )
        end

        getter shift : Types::Shift

        delegate :date, to: shift

        def time_worked : Time::Span
          resolved_time_worked || Time::Span.zero
        end

        def ongoing? : Bool
          shift.time_worked(@treat_paid_breaks_as_unpaid).nil? &&
            !shift.worked_so_far(@treat_paid_breaks_as_unpaid).nil?
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
          Representers::Shift.new(shift, expected_finish_time, expected_break_length)
        end

        private def resolved_time_worked : Time::Span?
          shift.time_worked(@treat_paid_breaks_as_unpaid) ||
            expected_time_worked ||
            shift.worked_so_far(@treat_paid_breaks_as_unpaid)
        end

        private def expected_time_worked : Time::Span?
          schedule = matching_schedule
          return unless schedule

          calculate_expected_time_worked(schedule)
        end

        private def matching_schedule : RegularHoursSchedule?
          return if shift.time_worked(@treat_paid_breaks_as_unpaid)
          return if shift.finish_time

          schedules = @regular_hours_schedules
          return unless schedules
          return if shift.date.date == Utils::Time.now.date

          schedules.find(&.day_of_week.==(shift.day_of_week))
        end

        private def calculate_expected_time_worked(schedule : RegularHoursSchedule) : Time::Span?
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

          actual_break_time = (@treat_paid_breaks_as_unpaid ? shift.valid_breaks : shift.valid_breaks.reject(&.paid?)).sum(&.ongoing_length).minutes
          expected_break_time = actual_break_time == 0.minutes ? schedule.break_length : 0.minutes
          total_break_time = actual_break_time + expected_break_time

          (expected_finish - start_time) - total_break_time
        end
      end
    end
  end
end
