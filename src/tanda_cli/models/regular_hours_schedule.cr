module TandaCLI
  module Models
    struct RegularHoursSchedule
      include JSON::Serializable
      include Utils::Mixins::PrettyTimes

      module TimeOfDayConverter
        FORMAT = "%H:%M"

        def self.from_json(value : JSON::PullParser) : Time
          Time.parse(value.read_string, FORMAT, Utils::Time.location)
        end

        def self.to_json(value : Time, json_builder : JSON::Builder) : Nil
          json_builder.string(value.to_s(FORMAT))
        end
      end

      module DayOfWeekConverter
        def self.from_json(value : JSON::PullParser) : Time::DayOfWeek
          day_string = value.read_string
          Time::DayOfWeek.parse?(day_string) || raise("Invalid day of week: #{day_string}")
        end

        def self.to_json(value : Time::DayOfWeek, json_builder : JSON::Builder) : Nil
          json_builder.string(value.to_s)
        end
      end

      def initialize(
        @day_of_week : Time::DayOfWeek,
        @start_time : Time,
        @finish_time : Time,
        @breaks : Array(Break) = Array(Break).new,
        @automatic_break_length : Time::Span = Time::Span.zero,
      ); end

      @[JSON::Field(converter: TandaCLI::Models::RegularHoursSchedule::DayOfWeekConverter)]
      getter day_of_week : Time::DayOfWeek

      @[JSON::Field(converter: TandaCLI::Models::RegularHoursSchedule::TimeOfDayConverter)]
      getter start_time : Time

      @[JSON::Field(converter: TandaCLI::Models::RegularHoursSchedule::TimeOfDayConverter)]
      getter finish_time : Time

      getter breaks : Array(Break)

      @[JSON::Field(converter: TandaCLI::API::Types::Converters::Span::FromMinutes)]
      getter automatic_break_length : Time::Span

      def length : Time::Span
        finish_time - start_time
      end

      def worked_length : Time::Span
        length - break_length
      end

      def break_length : Time::Span
        if (breaks = self.breaks).present?
          breaks.sum(&.length)
        else
          automatic_break_length
        end
      end
    end
  end
end
