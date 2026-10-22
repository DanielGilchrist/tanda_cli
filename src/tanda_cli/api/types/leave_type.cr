require "json"

module TandaCLI
  module API
    module Types
      struct LeaveType
        include JSON::Serializable

        getter name : String
        getter default_leave_length : Float64?

        def day_length : ::Time::Span?
          length = default_leave_length
          length.hours if length && length.positive?
        end
      end
    end
  end
end
