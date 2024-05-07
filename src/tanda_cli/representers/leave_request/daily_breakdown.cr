require "../base"
require "../../types/leave_request/daily_breakdown"

module TandaCLI
  module Representers
    class LeaveRequest::DailyBreakdown < Base(Types::LeaveRequest::DailyBreakdown)
      def initialize(object : T, @leave_request : Types::LeaveRequest)
        super(object)
      end

      private def build_display(builder : String::Builder)
        {% if flag?(:debug) %}
          builder << "Shift ID: #{@object.shift_id}\n"
          builder << "User ID: #{@leave_request.user_id}\n"
        {% end %}

        builder << "📅 #{@object.pretty_date}\n"

        start = @object.start_time
        finish = @object.finish_time
        builder << "🕔 #{start} - #{finish}\n" if start || finish

        builder << "🚧 #{@leave_request.status}\n"
        builder << "🌴 #{@leave_request.leave_type}\n"

        reason = @leave_request.reason
        builder << "ℹ️  #{reason}" if reason
      end
    end
  end
end
