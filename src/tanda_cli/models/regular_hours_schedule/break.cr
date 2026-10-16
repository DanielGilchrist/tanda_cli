module TandaCLI
  module Models
    struct RegularHoursSchedule
      struct Break
        include JSON::Serializable
        include Utils::Mixins::PrettyTimes

        def initialize(@start_time : Time, @finish_time : Time) : Nil; end

        @[JSON::Field(converter: TandaCLI::Models::RegularHoursSchedule::TimeOfDayConverter)]
        getter start_time : Time

        @[JSON::Field(converter: TandaCLI::Models::RegularHoursSchedule::TimeOfDayConverter)]
        getter finish_time : Time

        def length : Time::Span
          Utils::Time.span_between(start_time, finish_time)
        end

        def time_range : TimeRange
          TimeRange.new(TimeOfDay.from(start_time), TimeOfDay.from(finish_time))
        end
      end
    end
  end
end
