require "kebab"

module TandaCLI
  module Commands
    @[Kebab::Command(name: "balance", summary: "Check your leave balances")]
    struct Balance
      include Kebab::Parseable

      DEFAULT_LEAVE_TYPE = "Holiday Leave"

      def run(context : Context) : Nil
        display = context.display

        leave_balance = context.client.leave_balances
          .list(context.current.user.id)
          .or { |error| display.error!(error) }
          .find(&.leave_type.==(DEFAULT_LEAVE_TYPE))

        return display.error!("No leave balances to display") if leave_balance.nil?

        Representers::LeaveBalance.new(leave_balance).display(display)
      end
    end
  end
end
