require "./leave_breakdown/day"
require "./leave_breakdown/mismatch"

module TandaCLI
  module Models
    # A day by day account of a leave request, which only exists when it adds up to the hours being requested
    struct LeaveBreakdown
      alias Any = LeaveBreakdown | Mismatch

      def self.for(
        window : LeaveWindow,
        schedules : Array(RegularHoursSchedule),
        holidays : Hash(Time, String),
        charged : Time::Span,
      ) : Any?
        return if schedules.empty?

        days = days_for(window, schedules, holidays)
        return if days.empty?

        scheduled = days.sum(Time::Span.zero, &.hours)
        return Mismatch.new(charged, scheduled) unless scheduled == charged

        new(days)
      end

      private def self.days_for(
        window : LeaveWindow,
        schedules : Array(RegularHoursSchedule),
        holidays : Hash(Time, String),
      ) : Array(Day)
        days = Array(Day).new
        date = window.from

        while date <= window.to
          days << day_for(date, schedules, holidays)
          date = date.shift(days: 1)
        end

        days
      end

      private def self.day_for(date : Time, schedules : Array(RegularHoursSchedule), holidays : Hash(Time, String)) : Day
        name = holidays[date.at_beginning_of_day]?
        return Day.holiday(date, name) if name

        schedule = schedules.find(&.day_of_week.==(date.day_of_week))
        schedule ? Day.worked(date, schedule.worked_length) : Day.not_working(date)
      end

      private def initialize(@days : Array(Day)) : Nil; end

      getter days : Array(Day)

      def deducted_days : Int32
        @days.count(&.deducted?)
      end

      def crosses_year? : Bool
        first = @days.first?
        last = @days.last?
        return false if first.nil? || last.nil?

        first.date.year != last.date.year
      end
    end
  end
end
