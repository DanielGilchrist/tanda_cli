require "../client_builder"
require "./base"

module TandaCLI
  module Commands
    class Balance < Base
      include ClientBuilder

      required_scopes :leave

      DEFAULT_LEAVE_TYPE = "Holiday Leave"

      def setup_
        @name = "balance"
        @summary = @description = "Check your leave balances"
      end

      def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
        leave_balance = client.leave_balances.or(&.display!).find(&.leave_type.==(DEFAULT_LEAVE_TYPE))
        return Utils::Display.error!("No leave balances to display") if leave_balance.nil?

        Representers::LeaveBalance.new(leave_balance).display
      end
    end
  end
end
