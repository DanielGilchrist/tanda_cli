module TandaCLI
  class Configuration
    class Serialisable
      class Organisation
        class RegularHoursSchedule
          include JSON::Serializable
          include Utils::Mixins::PrettyTimes

          module DayConverter
            def self.from_json(value : JSON::PullParser) : Time::DayOfWeek
              day_string = value.read_string
              Time::DayOfWeek.parse?(day_string) || raise("Invalid day of week: #{day_string}")
            end

            def self.to_json(value, json_builder : JSON::Builder)
              json_builder.string(value.to_s)
            end
          end

          class Break
            include JSON::Serializable
            include Utils::Mixins::PrettyTimes

            def initialize(@_start_time : String, @_finish_time : String); end

            def start_time : Time
              Time.parse(@_start_time, TIME_STRING_FORMAT, Utils::Time.location)
            end

            def finish_time : Time
              Time.parse(@_finish_time, TIME_STRING_FORMAT, Utils::Time.location)
            end

            def length : Time::Span
              finish_time - start_time
            end
          end

          def initialize(
            @day_of_week : Time::DayOfWeek,
            start_time : (String | Time),
            finish_time : (String | Time),
            @breaks : Array(Break) = Array(Break).new,
            @automatic_break_length : UInt16 = 0,
          )
            # TODO: I don't believe we should have to `.as(String)` here
            @_start_time = begin
              case start_time
              in String
                start_time
              in Time
                start_time.to_s(TIME_STRING_FORMAT)
              end
            end.as(String)

            # TODO: I don't believe we should have to `.as(String)` here
            @_finish_time = begin
              case finish_time
              in String
                finish_time
              in Time
                finish_time.to_s(TIME_STRING_FORMAT)
              end
            end.as(String)
          end

          @[JSON::Field(converter: TandaCLI::Configuration::Serialisable::Organisation::RegularHoursSchedule::DayConverter)]
          getter day_of_week : Time::DayOfWeek

          getter breaks : Array(Break)

          getter automatic_break_length : UInt16?

          def start_time : Time
            Time.parse(@_start_time, TIME_STRING_FORMAT, Utils::Time.location)
          end

          def finish_time : Time
            Time.parse(@_finish_time, TIME_STRING_FORMAT, Utils::Time.location)
          end

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
              (automatic_break_length || 0).minutes
            end
          end
        end
      end
    end
  end
end
