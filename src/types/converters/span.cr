require "json"

module Tanda::CLI
  module Types
    module Converters::Span
      module FromHoursFloat
        def self.from_json(value : JSON::PullParser) : ::Time::Span
          value.read_float.hours
        end
      end
    end
  end
end
