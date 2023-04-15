require "json"
require "./converters/span.cr"

module Tanda::CLI
  module Types
    class LeaveBalance
      include JSON::Serializable

      getter hours : Float32
      getter leave_type : String

      def pretty_hours : String
        "#{hours} hours"
      end
    end
  end
end
