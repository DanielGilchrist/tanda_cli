require "json"

module Tanda::CLI
  module Types
    module Converters::Time
      def self.from_json(value : JSON::PullParser) : ::Time?
        timestamp = value.read_int_or_null
        return unless timestamp

        ::Time.unix(timestamp.to_i32).in(Current.user!.time_zone)
      end
    end
  end
end
