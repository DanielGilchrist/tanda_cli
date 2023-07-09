require "./base"
require "../types/leave_balance"

module Tanda::CLI
  module Representers
    class LeaveBalance < Base(Types::LeaveBalance)
      private def build_display(builder : String::Builder)
        builder << "Leave Balance\n"
        with_padding("⏳ #{@object.pretty_hours}", builder)
        with_padding("🌴 #{@object.leave_type}", builder)
      end
    end
  end
end
