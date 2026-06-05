module TandaCLI
  module Models
    struct RegularHoursSchedule
      struct Break
        include JSON::Serializable
        include Utils::Mixins::PrettyTimes

        def initialize(@start_time : Time, @finish_time : Time); end

        @[JSON::Field(converter: TandaCLI::Models::RegularHoursSchedule::TimeOfDayConverter)]
        getter start_time : Time

        @[JSON::Field(converter: TandaCLI::Models::RegularHoursSchedule::TimeOfDayConverter)]
        getter finish_time : Time

        def length : Time::Span
          finish_time - start_time
        end
      end
    end
  end
end
