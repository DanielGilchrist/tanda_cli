require "./base"
require "../types/leave_balance"

module Tanda::CLI
  module Representers
    class LeaveBalance < Base(Types::LeaveBalance)
      private def build_display(builder : String::Builder)
        builder << "Leave Balance\n"
        titled_with_padding("Hours", object.pretty_hours, builder)
        titled_with_padding("Leave Type", object.leave_type, builder)
      end
    end
  end
end
