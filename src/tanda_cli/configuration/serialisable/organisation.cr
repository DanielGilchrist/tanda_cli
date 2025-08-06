require "../../utils/mixins/pretty_times"

module TandaCLI
  class Configuration
    class Serialisable
      class Organisation
        include JSON::Serializable

        TIME_STRING_FORMAT = "%H:%M"

        def self.from(organisation : Types::Me::Organisation) : self
          new(
            organisation.id,
            organisation.name,
            organisation.user_id
          )
        end

        def self.from(me : Types::Me) : Array(self)
          me.organisations.map(&->from(Types::Me::Organisation))
        end

        def initialize(
          @id : Int32,
          @name : String,
          @user_id : Int32,
          @current : Bool = false,
          @_regular_hours_schedules : Array(RegularHoursSchedule)? = nil,
        ); end

        getter id : Int32
        getter name : String
        getter user_id : Int32
        property? current : Bool

        @[JSON::Field(key: "regular_hours")]
        private getter _regular_hours_schedules : Array(RegularHoursSchedule)?

        def regular_hours_schedules : Array(RegularHoursSchedule)
          @_regular_hours_schedules || Array(RegularHoursSchedule).new
        end

        def set_regular_hours!(schedules_with_day_of_week : Array({day_of_week: Time::DayOfWeek, schedule: Types::Schedule}))
          @_regular_hours_schedules = schedules_with_day_of_week.compact_map do |schedule_with_day_of_week|
            schedule = schedule_with_day_of_week[:schedule]
            day_of_week = schedule_with_day_of_week[:day_of_week]

            schedule_start_time = schedule.start_time
            schedule_finish_time = schedule.finish_time
            next if schedule_start_time.nil? || schedule_finish_time.nil?

            breaks = begin
              if (schedule_breaks = schedule.breaks).empty?
                Array(RegularHoursSchedule::Break).new
              else
                schedule_breaks.compact_map do |schedule_break|
                  start_time = schedule_break.start_time
                  finish_time = schedule_break.finish_time
                  next if start_time.nil? || finish_time.nil?

                  RegularHoursSchedule::Break.new(
                    start_time.to_s(TIME_STRING_FORMAT),
                    finish_time.to_s(TIME_STRING_FORMAT)
                  )
                end
              end
            end

            RegularHoursSchedule.new(
              day_of_week: day_of_week,
              breaks: breaks,
              automatic_break_length: schedule.automatic_break_length,
              start_time: schedule_start_time,
              finish_time: schedule_finish_time
            )
          end
        end
      end
    end
  end
end
