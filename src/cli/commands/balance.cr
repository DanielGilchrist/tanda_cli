require "../client_builder"
require "./base"

module Tanda::CLI
  module CLI::Commands
    class Balance < Base
      include CLI::ClientBuilder

      DEFAULT_LEAVE_TYPE = "Holiday Leave"

      def on_setup
        @name = "balance"
        @summary = @description = "Check your leave balances"
      end

      def run(arguments : Cling::Arguments, options : Cling::Options) : Nil
        leave_balance = client.leave_balances.or(&.display!).find(&.leave_type.==(DEFAULT_LEAVE_TYPE))
        return Utils::Display.error!("No leave balances to display") if leave_balance.nil?

        Representers::LeaveBalance.new(leave_balance).display
      end
    end
  end
end
