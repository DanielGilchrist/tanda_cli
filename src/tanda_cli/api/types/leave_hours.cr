require "json"

module TandaCLI
  module API
    module Types
      struct LeaveHours
        include JSON::Serializable

        HOURS_KEYS = {"hours", "leave_hours", "default_hours"}

        def self.new(pull : JSON::PullParser) : LeaveHours
          case pull.kind
          in .int?, .float?
            new(pull.read_float)
          in .string?
            new(pull.read_string.to_f? || 0.0)
          in .begin_object?
            from_object(pull)
          in .null?
            pull.read_null
            new(0.0)
          in .begin_array?, .bool?, .end_array?, .end_object?, .eof?
            pull.skip
            new(0.0)
          end
        end

        private def self.from_object(pull : JSON::PullParser) : LeaveHours
          hours = 0.0

          pull.read_object do |key|
            if HOURS_KEYS.includes?(key) && hours.zero?
              hours = read_number(pull)
            else
              pull.skip
            end
          end

          new(hours)
        end

        private def self.read_number(pull : JSON::PullParser) : Float64
          case pull.kind
          in .int?, .float?
            pull.read_float
          in .string?
            pull.read_string.to_f? || 0.0
          in .null?, .begin_array?, .begin_object?, .bool?, .end_array?, .end_object?, .eof?
            pull.skip
            0.0
          end
        end

        def initialize(@hours : Float64) : Nil; end

        getter hours : Float64

        def span : ::Time::Span
          @hours.hours
        end
      end
    end
  end
end
