require "../base"
require "../../api/types/leave_request/daily_breakdown"

module TandaCLI
  module Representers
    struct LeaveRequest::DailyBreakdown < Base(API::Types::LeaveRequest::DailyBreakdown)
      def initialize(object : T, @leave_request : API::Types::LeaveRequest)
        super(object)
      end

      private def build_display(builder : Builder)
        builder << "📅 #{@object.pretty_date}\n"

        start = @object.start_time
        finish = @object.finish_time
        builder << "🕔 #{start} - #{finish}\n" if start || finish

        builder << "🚧 #{@leave_request.status}\n"
        builder << "🌴 #{@leave_request.leave_type}\n"

        reason = @leave_request.reason
        if reason && !reason.blank?
          builder << "ℹ️  #{reason}\n"
        end
      end
    end
  end
end
