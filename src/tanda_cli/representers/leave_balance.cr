require "./base"
require "../api/types/leave_balance"

module TandaCLI
  module Representers
    struct LeaveBalance < Base(API::Types::LeaveBalance)
      private def build_display(builder : Builder)
        builder << "Leave Balance\n"
        with_padding("⏳ #{@object.pretty_hours}", builder)
        with_padding("🌴 #{@object.leave_type}", builder)
      end
    end
  end
end
