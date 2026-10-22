require "./base"
require "../api/types/leave_balance"
require "../utils/duration"

module TandaCLI
  module Representers
    struct LeaveBalance < Base(API::Types::LeaveBalance)
      private def build_display(builder : Builder) : Nil
        builder << "Leave Balance\n"
        with_padding("⏳ #{Utils::Duration.compact(@object.span)}", builder)
        with_padding("🌴 #{@object.leave_type}", builder)
      end
    end
  end
end
