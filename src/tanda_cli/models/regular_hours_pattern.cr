module TandaCLI
  module Models
    struct RegularHoursPattern
      alias OrganisationConfig = Configuration::Serialisable::Organisation
      alias RegularHoursSchedule = OrganisationConfig::RegularHoursSchedule

      def self.from_rosters(rosters : Array(API::Types::Roster), user_id : Int32) : self
        candidates_by_day = Hash(Time::DayOfWeek, Array(Candidate)).new { |hash, key| hash[key] = Array(Candidate).new }
        seen_dates = Set(Time).new
        weeks_with_data = 0

        rosters.each do |roster|
          week_has_data = false
          roster.daily_schedules.each do |daily|
            next if seen_dates.includes?(daily.date)

            candidate = Candidate.from?(daily, user_id)
            next if candidate.nil?

            seen_dates << daily.date
            candidates_by_day[candidate.day_of_week] << candidate
            week_has_data = true
          end

          weeks_with_data += 1 if week_has_data
        end

        entries = candidates_by_day.map do |day_of_week, candidates|
          most_recent = candidates.max_by(&.source_date)
          Entry.new(
            day_of_week: day_of_week,
            start_time: most_recent.start_time,
            finish_time: most_recent.finish_time,
            automatic_break_length: most_recent.automatic_break_length,
            breaks: most_recent.breaks,
            source_date: most_recent.source_date,
            weeks_seen: candidates.size,
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
            breaks: entry.breaks.map { |brk| build_persisted_break(brk) },
            automatic_break_length: entry.automatic_break_length,
          )
        end
      end

      def representer : Representers::RegularHoursPattern
        Representers::RegularHoursPattern.new(self)
      end

      private def build_persisted_break(brk : Break) : RegularHoursSchedule::Break
        RegularHoursSchedule::Break.new(
          brk.start_time.to_s(OrganisationConfig::TIME_STRING_FORMAT),
          brk.finish_time.to_s(OrganisationConfig::TIME_STRING_FORMAT),
        )
      end
    end
  end
end
