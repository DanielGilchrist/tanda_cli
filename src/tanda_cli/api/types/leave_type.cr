require "json"

module TandaCLI
  module API
    module Types
      struct LeaveType
        include JSON::Serializable

        NAME_KEYS = {"name", "leave_type", "title", "type"}

        def self.new(pull : JSON::PullParser) : LeaveType
          case pull.kind
          in .string?
            new(pull.read_string)
          in .begin_object?
            from_object(pull)
          in .null?
            pull.read_null
            new("")
          in .begin_array?, .int?, .float?, .bool?, .end_array?, .end_object?, .eof?
            pull.skip
            new("")
          end
        end

        private def self.from_object(pull : JSON::PullParser) : LeaveType
          name = ""

          pull.read_object do |key|
            if NAME_KEYS.includes?(key) && name.empty?
              name = pull.read_string
            else
              pull.skip
            end
          end

          new(name)
        end

        def initialize(@name : String) : Nil; end

        getter name : String

        def named? : Bool
          !@name.blank?
        end
      end
    end
  end
end
