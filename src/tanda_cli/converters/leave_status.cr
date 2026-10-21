require "kebab"
require "../api/types/leave_request"

module TandaCLI
  module Converters
    module LeaveStatus
      extend self

      def convert(input : String) : API::Types::LeaveRequest::Status::Known | Kebab::Convert::Failure
        API::Types::LeaveRequest::Status::Known.parse?(input.strip) ||
          Kebab::Convert.failure("try one of #{known_statuses.join(", ")}", name: "leave status")
      end

      private def known_statuses : Array(String)
        API::Types::LeaveRequest::Status::Known.values.map(&.to_s.downcase)
      end
    end
  end
end
