require "json"

module TandaCLI
  module API
    module Types
      struct LeaveType
        include JSON::Serializable

        getter name : String
        getter default_leave_length : Float64?

        @[JSON::Field(key: "view_in_days")]
        getter? in_days : Bool = false

        @[JSON::Field(key: "prevent_negative")]
        getter? prevents_negative : Bool = false

        def day_length : ::Time::Span?
          length = default_leave_length
          length.hours if length && length.positive?
        end
      end
    end
  end
end
