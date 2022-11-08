require "json"

module Tanda::CLI
  module Types
    module Converters::Time

      module FromUnix
        def self.from_json(value : JSON::PullParser) : ::Time?
          timestamp = value.read_int
          ::Time.unix(timestamp.to_i32).in(Current.user.time_zone)
        end
      end

      module FromMaybeUnix
        def self.from_json(value : JSON::PullParser) : ::Time?
          timestamp = value.read_int_or_null
          return unless timestamp

          ::Time.unix(timestamp.to_i32).in(Current.user.time_zone)
        end
      end

      module FromISODate
        def self.from_json(value : JSON::PullParser) : ::Time
          date = value.read_string
          ::Time.parse(date, "%Y-%m-%d", Current.user.time_zone)
        end
      end
    end
  end
end
