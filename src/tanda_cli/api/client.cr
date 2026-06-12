require "./request"
require "./resources/*"

module TandaCLI
  module API
    class Client
      def initialize(base_uri : String, token : String, current_user : Current::User? = nil)
        @request = Request.new(base_uri, token, current_user)
      end

      def shifts : Resources::Shifts
        Resources::Shifts.new(@request)
      end

      def clock_ins : Resources::ClockIns
        Resources::ClockIns.new(@request)
      end

      def leave_balances : Resources::LeaveBalances
        Resources::LeaveBalances.new(@request)
      end

      def leave_requests : Resources::LeaveRequests
        Resources::LeaveRequests.new(@request)
      end

      def users : Resources::Users
        Resources::Users.new(@request)
      end

      def personal_details : Resources::PersonalDetails
        Resources::PersonalDetails.new(@request)
      end

      def rosters : Resources::Rosters
        Resources::Rosters.new(@request)
      end
    end
  end
end
