require "json"
require "./converters/span.cr"

module TandaCLI
  module Types
    struct LeaveBalance
      include JSON::Serializable

      getter hours : Float32
      getter leave_type : String

      def pretty_hours : String
        "#{hours} hours"
      end
    end
  end
end
