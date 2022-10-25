module Tanda::CLI
  module CLI::Commands
    class ClockIn
      def initialize(@client : API::Client, @clock_type : String); end

      def execute
        now = Utils::Time.now
        client.send_clockin(now, clock_type)
      end

      private getter client
      private getter clock_type
    end
  end
end
