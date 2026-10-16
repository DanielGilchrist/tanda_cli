require "../error/no_regular_hours_for_day"
require "./regular_hours_schedule"
require "./regular_hours_week/edit"

module TandaCLI
  module Models
    struct RegularHoursWeek
      def self.from(schedules : Array(RegularHoursSchedule)) : self
        new(schedules.to_h { |schedule| {schedule.day_of_week, schedule} })
      end

      def self.empty : self
        new(Hash(Time::DayOfWeek, RegularHoursSchedule).new)
      end

      def initialize(@schedules : Hash(Time::DayOfWeek, RegularHoursSchedule)) : Nil; end

      def [](day_of_week : Time::DayOfWeek) : RegularHoursSchedule?
        @schedules[day_of_week]?
      end

      def empty? : Bool
        @schedules.empty?
      end

      def days_in_order(start_of_week : Time::DayOfWeek) : Array(Time::DayOfWeek)
        Time::DayOfWeek.values.rotate(start_of_week.value - 1)
      end

      def to_schedules : Array(RegularHoursSchedule)
        @schedules.values.sort_by!(&.day_of_week.value)
      end

      def representer(
        start_of_week : Time::DayOfWeek,
        changed : Array(Time::DayOfWeek) = Array(Time::DayOfWeek).new,
        only_changed : Bool = false,
      ) : Representers::RegularHoursWeek
        Representers::RegularHoursWeek.new(self, start_of_week, changed, only_changed)
      end

      def total_worked : Time::Span
        @schedules.values.sum(Time::Span.zero, &.worked_length)
      end

      def keep_only(days : Set(Time::DayOfWeek)) : RegularHoursWeek
        RegularHoursWeek.new(@schedules.select { |day_of_week, _| days.includes?(day_of_week) })
      end

      def changes_from(other : RegularHoursWeek) : Array(Time::DayOfWeek)
        Time::DayOfWeek.values.reject { |day_of_week| same_day?(other, day_of_week) }
      end

      def apply(edit : Edit::Any) : RegularHoursWeek | Error::Base
        schedules = @schedules.dup

        case edit
        in Edit::Hours
          edit.days.days.each do |day_of_week|
            existing_plan = schedules[day_of_week]?.try(&.break_plan)
            break_plan = edit.break_plan || existing_plan || BreakPlan::None.new

            case built = RegularHoursSchedule.build(day_of_week, edit.hours, break_plan)
            in RegularHoursSchedule
              schedules[day_of_week] = built
            in Error::Base
              return built
            end
          end
        in Edit::Break
          scheduled = edit.days.days.select { |day_of_week| schedules.has_key?(day_of_week) }
          if scheduled.empty?
            return no_hours_for(edit.days.days.first, "break #{edit.break_plan}")
          end

          scheduled.each do |day_of_week|
            case built = schedules[day_of_week].with_break_plan(edit.break_plan)
            in RegularHoursSchedule
              schedules[day_of_week] = built
            in Error::Base
              return built
            end
          end
        in Edit::Remove
          edit.days.days.each { |day_of_week| schedules.delete(day_of_week) }
        in Edit::Copy
          source = schedules[edit.from]?
          return no_hours_for(edit.from, "break 30m") if source.nil?

          edit.days.days.each do |day_of_week|
            next if day_of_week == edit.from

            built = RegularHoursSchedule.build(day_of_week, source.hours, source.break_plan)
            case built
            in RegularHoursSchedule
              schedules[day_of_week] = built
            in Error::Base
              return built
            end
          end
        end

        RegularHoursWeek.new(schedules)
      end

      private def no_hours_for(
        day_of_week : Time::DayOfWeek,
        suffix : String,
      ) : Error::NoRegularHoursForDay
        example = "#{day_of_week.to_s.downcase[0, 3]} 9-17 #{suffix}"
        Error::NoRegularHoursForDay.new(day_of_week, example)
      end

      private def same_day?(other : RegularHoursWeek, day_of_week : Time::DayOfWeek) : Bool
        mine = self[day_of_week]
        theirs = other[day_of_week]
        return mine.nil? && theirs.nil? if mine.nil? || theirs.nil?

        mine.same_as?(theirs)
      end
    end
  end
end
