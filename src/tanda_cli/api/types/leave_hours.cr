require "json"

module TandaCLI
  module API
    module Types
      struct LeaveHours
        include JSON::Serializable

        getter hours : Float64

        def span : ::Time::Span
          @hours.hours
        end
      end
    end
  end
end
