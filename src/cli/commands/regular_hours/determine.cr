module Tanda::CLI
  module CLI::Commands
    class RegularHours::Determine
      def initialize(@client : API::Client); end

      def execute
        user = client.user(id: Current.user.id, show_regular_hours: true, force: true).or(&.display!)
        pp user
      end

      private getter client : API::Client
    end
  end
end
