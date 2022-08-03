require "json"

module Tanda::CLI
  module Types
    module Converters::Time
      def self.from_json(value : JSON::PullParser) : ::Time?
        timestamp = value.read_int_or_null

        time = ::Time.unix(timestamp.to_i32)
        time.in(::Time::Location.load("Europe/London")) # TODO: Don't hard-code time zone
      end
    end
  end
end
