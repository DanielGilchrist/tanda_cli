require "json"
require "./converters/time"

module Tanda::CLI
  module Types
    class ShiftBreak
      include JSON::Serializable
      include Utils::Mixins::PrettyTimes

      getter id : Int32
      getter shift_id : Int32
      getter length : UInt16 # length in minutes

      @[JSON::Field(key: "start", converter: Tanda::CLI::Types::Converters::Time::FromMaybeUnix)]
      getter start_time : Time?

      @[JSON::Field(key: "finish", converter: Tanda::CLI::Types::Converters::Time::FromMaybeUnix)]
      getter finish_time : Time?

      def ongoing_length : UInt16
        start_time = self.start_time
        finish_time = self.finish_time
        return length if finish_time || start_time.nil?

        (Utils::Time.now - start_time).minutes.to_u16
      end

      def pretty_ongoing_length : String
        "#{ongoing_length} minutes"
      end
    end
  end
end
