module TandaCLI
  module API
    class Client
      def initialize(@base_uri : String, @token : String, @display : Display, @current_user : Current::User? = nil)
        @request = Request.new(@base_uri, @token, @display, @current_user)
      end

      def clock_ins : ClockIns
        ClockIns.new(@request)
      end

      def leave_balances : LeaveBalances
        LeaveBalances.new(@request)
      end

      def leave_requests : LeaveRequests
        LeaveRequests.new(@request)
      end

      def me : Me
        Me.new(@request)
      end

      def personal_details : PersonalDetails
        PersonalDetails.new(@request)
      end

      def rosters : Rosters
        Rosters.new(@request)
      end

      def shifts : Shifts
        Shifts.new(@request, self)
      end
    end
  end
end
