module Tanda::CLI
  class CLI::Parser
    class LeaveBalance
      DEFAULT_LEAVE_TYPE = "Holiday Leave"

      def initialize(@parser : OptionParser, @client : API::Client); end

      def parse
        leave_balance = client.leave_balances.or(&.display!).find(&.leave_type.==(DEFAULT_LEAVE_TYPE))
        return Utils::Display.error!("No leave balances") if leave_balance.nil?

        Representers::LeaveBalance.new(leave_balance).display
      end

      private getter parser : OptionParser
      private getter client : API::Client
    end
  end
end
