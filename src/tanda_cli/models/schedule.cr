module TandaCLI
  module Models
    struct Schedule
      def self.from?(daily : API::Types::Roster::DailySchedule, user_id : Int32) : Schedule?
        schedule = daily.schedules.find(&.user_id.==(user_id))
        return if schedule.nil?

        start_time = schedule.start_time
        finish_time = schedule.finish_time
        return if start_time.nil? || finish_time.nil?

        new(
          date: daily.date,
          user_id: user_id,
          start_time: start_time,
          finish_time: finish_time,
          automatic_break_length: schedule.automatic_break_length,
          breaks: schedule.breaks.compact_map { |schedule_break| Break.from?(schedule_break) },
        )
      end

      def initialize(
        @date : Time,
        @user_id : Int32,
        @start_time : Time,
        @finish_time : Time,
        @automatic_break_length : UInt16,
        @breaks : Array(Break),
      ); end

      getter date : Time
      getter user_id : Int32
      getter start_time : Time
      getter finish_time : Time
      getter automatic_break_length : UInt16
      getter breaks : Array(Break)

      def day_of_week : Time::DayOfWeek
        date.day_of_week
      end
    end
  end
end
