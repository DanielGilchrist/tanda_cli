module TandaCLI
  module Models
    struct RegularHoursPattern
      struct Candidate
        def self.from?(daily : Types::Roster::DailySchedule, user_id : Int32) : Candidate?
          schedule = daily.schedules.find(&.user_id.==(user_id))
          return if schedule.nil?

          start_time = schedule.start_time
          finish_time = schedule.finish_time
          return if start_time.nil? || finish_time.nil?

          new(
            day_of_week: daily.date.day_of_week,
            start_time: start_time,
            finish_time: finish_time,
            automatic_break_length: schedule.automatic_break_length,
            breaks: schedule.breaks.compact_map { |schedule_break| Break.from?(schedule_break) },
            source_date: daily.date,
          )
        end

        def initialize(
          @day_of_week : Time::DayOfWeek,
          @start_time : Time,
          @finish_time : Time,
          @automatic_break_length : UInt16,
          @breaks : Array(Break),
          @source_date : Time,
        ); end

        getter day_of_week : Time::DayOfWeek
        getter start_time : Time
        getter finish_time : Time
        getter automatic_break_length : UInt16
        getter breaks : Array(Break)
        getter source_date : Time
      end
    end
  end
end
