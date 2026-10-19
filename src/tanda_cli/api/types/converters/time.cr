require "json"

module TandaCLI
  module API
    module Types
      module Converters::Time
        module FromUnix
          extend self

          def from_json(value : JSON::PullParser) : ::Time
            timestamp = value.read_int
            ::Time.unix(timestamp.to_i32).in(Utils::Time.location)
          end

          def to_json(value : ::Time, json_builder : JSON::Builder) : Nil
            json_builder.number(value.to_unix.to_i)
          end
        end

        module FromMaybeUnix
          extend self

          def from_json(value : JSON::PullParser) : ::Time?
            timestamp = value.read_int_or_null
            return unless timestamp

            ::Time.unix(timestamp.to_i32).in(Utils::Time.location)
          end
        end

        module FromISODate
          extend self

          FORMAT = "%Y-%m-%d"

          def from_json(value : JSON::PullParser) : ::Time
            date = value.read_string
            ::Time.parse(date, FORMAT, Utils::Time.location)
          end
        end
      end
    end
  end
end
