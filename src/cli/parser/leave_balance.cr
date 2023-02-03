module Tanda::CLI
  class CLI::Parser
    class LeaveBalance < APIParser
      DEFAULT_LEAVE_TYPE = "Holiday Leave"

      def parse
        leave_balance = client.leave_balances.or(&.display!).find(&.leave_type.==(DEFAULT_LEAVE_TYPE))
        return Utils::Display.error!("No leave balances to display") if leave_balance.nil?

        Representers::LeaveBalance.new(leave_balance).display
      end
    end
  end
end
