require "../base"
require "../../types/leave_request/daily_breakdown"

module Tanda::CLI
  module Representers
    class LeaveRequest::DailyBreakdown < Base(Types::LeaveRequest::DailyBreakdown)
      def initialize(object : T, @leave_request : Types::LeaveRequest)
        super(object)
      end

      private def build_display(builder : String::Builder)
        {% if flag?(:debug) %}
          builder << "Shift ID: #{object.shift_id}\n"
          builder << "User ID: #{leave_request.user_id}\n"
        {% end %}

        builder << "Date: #{object.pretty_date}\n"

        start = object.start_time
        builder << "Start: #{start}\n" if start

        finish = object.finish_time
        builder << "Finish: #{finish}\n" if finish

        builder << "Status: #{leave_request.status}\n"
        builder << "Leave type: #{leave_request.leave_type}\n"
      end

      private getter leave_request : Types::LeaveRequest
    end
  end
end
