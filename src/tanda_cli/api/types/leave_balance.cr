require "json"
require "./converters/span.cr"

module TandaCLI
  module API
    module Types
      struct LeaveBalance
        include JSON::Serializable

        getter hours : Float32
        getter leave_type : String

        def span : ::Time::Span
          hours.to_f64.hours
        end
      end
    end
  end
end
