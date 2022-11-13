require "./base"
require "../types/leave_request"

module Tanda::CLI
  module Representers
    class LeaveRequest < Base(Types::LeaveRequest)
      def display
        puts "ID: #{object.id}"
        puts "User ID: #{object.user_id}"

        start, finish = object.pretty_dates
        puts "Start: #{start}"
        puts "Finish: #{finish}"

        puts "Status: #{object.status}"
      end
    end
  end
end
