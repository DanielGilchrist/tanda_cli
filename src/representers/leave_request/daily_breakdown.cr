require "../base"
require "../../types/leave_request/daily_breakdown"

module Tanda::CLI
  module Representers
    class LeaveRequest::DailyBreakdown < Base(Types::LeaveRequest::DailyBreakdown)
      def initialize(object : T, @leave_request : Types::LeaveRequest)
        super(object)
      end

      def display
        puts "Shift ID: #{object.shift_id}"
        puts "User ID: #{leave_request.user_id}"
        puts "Date: #{object.pretty_date}"

        start = object.start_time
        puts "Start: #{start}" if start

        finish = object.finish_time
        puts "Finish: #{finish}" if finish

        puts "Status: #{leave_request.status}"
        puts "Leave type: #{leave_request.leave_type}"

        puts "\n"
      end

      private getter leave_request : Types::LeaveRequest
    end
  end
end
