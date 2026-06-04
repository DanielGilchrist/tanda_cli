module TandaCLI
  module Models
    struct RegularHoursPattern
      def self.from_rosters(rosters : Array(API::Types::Roster), user_id : Int32) : self
        schedules_by_day = Hash(Time::DayOfWeek, Array(Schedule)).new { |hash, key| hash[key] = Array(Schedule).new }
        seen_dates = Set(Time).new
        weeks_with_data = 0

        rosters.each do |roster|
          week_has_data = false
          roster.daily_schedules.each do |daily|
            next if seen_dates.includes?(daily.date)

            schedule = Schedule.from?(daily, user_id)
            next if schedule.nil?

            seen_dates << daily.date
            schedules_by_day[schedule.day_of_week] << schedule
            week_has_data = true
          end

          weeks_with_data += 1 if week_has_data
        end

        entries = schedules_by_day.map do |day_of_week, schedules|
          most_recent = schedules.max_by(&.date)
          Entry.new(
            day_of_week: day_of_week,
            start_time: most_recent.start_time,
            finish_time: most_recent.finish_time,
            automatic_break_length: most_recent.automatic_break_length,
            breaks: most_recent.breaks,
            source_date: most_recent.date,
            weeks_seen: schedules.size,
          )
        end.sort_by!(&.day_of_week.to_i)

        new(entries: entries, weeks_probed: rosters.size, weeks_with_data: weeks_with_data)
      end

      def initialize(
        @entries : Array(Entry),
        @weeks_probed : Int32,
        @weeks_with_data : Int32,
      ); end

      getter entries : Array(Entry)
      getter weeks_probed : Int32
      getter weeks_with_data : Int32

      def empty? : Bool
        @entries.empty?
      end

      def to_regular_hours_schedules : Array(RegularHoursSchedule)
        @entries.map do |entry|
          RegularHoursSchedule.new(
            day_of_week: entry.day_of_week,
            start_time: entry.start_time,
            finish_time: entry.finish_time,
            breaks: entry.breaks.map { |brk| RegularHoursSchedule::Break.new(brk.start_time, brk.finish_time) },
            automatic_break_length: entry.automatic_break_length,
          )
        end
      end

      def representer : Representers::RegularHoursPattern
        Representers::RegularHoursPattern.new(self)
      end
    end
  end
end
