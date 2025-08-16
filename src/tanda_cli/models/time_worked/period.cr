module TandaCLI
  module Models
    module TimeWorked
      abstract class Period
        alias RegularHoursSchedule = Configuration::Serialisable::Organisation::RegularHoursSchedule

        def initialize(@context : Context, @offset : Int32?)
        end

        abstract def fetch_shifts : Array(Types::Shift)
        abstract def calculate_and_display(display_details : Bool = false)

        protected def fetch_visible_shifts(from : Time, to : Time? = nil) : Array(Types::Shift)
          to ||= from

          @context
            .client
            .shifts(@context.current.user.id, from, to, show_notes: false)
            .or { |error| @context.display.error!(error) }
            .select(&.visible?)
        end

        protected def display_shift_details(shifts : Array(Types::Shift), calculator : Calculator, regular_hours_schedules : Array(RegularHoursSchedule)? = nil)
          shifts.each do |shift|
            leave_request = shift.leave_request
            breakdown = leave_request.breakdown_for(shift) if leave_request

            if leave_request && breakdown
              display_leave(leave_request, breakdown)
              next
            end

            treat_paid_breaks_as_unpaid = @context.config.treat_paid_breaks_as_unpaid? || false
            time_worked = shift.time_worked(treat_paid_breaks_as_unpaid)
            worked_so_far = shift.worked_so_far(treat_paid_breaks_as_unpaid)

            if time_worked.nil? && shift.finish_time.nil? && regular_hours_schedules
              time_worked = calculator.calculate_expected_time_worked(shift, regular_hours_schedules)
              calculator.warn_missing_finish_time(shift) if time_worked
            end

            display_shift(shift, time_worked, worked_so_far, regular_hours_schedules)
          end
        end

        private def display_shift(shift : Types::Shift, time_worked : Time::Span?, worked_so_far : Time::Span?, regular_hours_schedules : Array(RegularHoursSchedule)? = nil)
          if time_worked
            @context.stdout.puts "#{"Time worked:".colorize.white.bold} #{time_worked.hours} hours and #{time_worked.minutes} minutes"
          elsif worked_so_far
            @context.stdout.puts "#{"Worked so far:".colorize.white.bold} #{worked_so_far.hours} hours and #{worked_so_far.minutes} minutes"
          end

          expected_finish_time = nil
          expected_break_length = nil
          if shift.finish_time.nil? && regular_hours_schedules
            schedule = regular_hours_schedules.find(&.day_of_week.==(shift.day_of_week))
            if schedule && shift.date.date != Utils::Time.now.date
              expected_finish_time = Utils::Time.pretty_time(schedule.finish_time)
              expected_break_length = schedule.break_length
            end
          end

          Representers::Shift.new(shift, expected_finish_time, expected_break_length).display(@context.stdout)
        end

        private def display_leave(leave_request : Types::LeaveRequest, breakdown : Types::LeaveRequest::DailyBreakdown)
          length = breakdown.hours

          # Don't bother showing days where there are no hours for leave
          return if length.zero?

          @context.stdout.puts "#{"Leave taken:".colorize.white.bold} #{length.hours} hours and #{length.minutes} minutes"

          Representers::LeaveRequest::DailyBreakdown.new(breakdown, leave_request).display(@context.stdout)
        end
      end
    end
  end
end
