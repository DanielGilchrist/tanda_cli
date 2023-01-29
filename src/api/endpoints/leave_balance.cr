require "./interface.cr"
require "../client"

module Tanda::CLI
  module API
    module Endpoints::LeaveBalance
      include Endpoints::Interface

      def leave_balances : API::Result(Array(Types::LeaveBalance))
        response = get("/leave_balances", query: {
          "user_ids" => Current.user.id.to_s,
        })

        API::Result(Array(Types::LeaveBalance)).from(response)
      end
    end
  end
end