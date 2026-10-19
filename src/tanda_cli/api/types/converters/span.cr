require "json"

module TandaCLI
  module API
    module Types
      module Converters::Span
        module FromHoursFloat
          extend self

          def from_json(value : JSON::PullParser) : ::Time::Span
            value.read_float.hours
          end
        end

        module FromMinutes
          extend self

          def from_json(value : JSON::PullParser) : ::Time::Span
            value.read_int.minutes
          end

          def to_json(value : ::Time::Span, json_builder : JSON::Builder) : Nil
            json_builder.number(value.total_minutes.to_i)
          end
        end
      end
    end
  end
end
