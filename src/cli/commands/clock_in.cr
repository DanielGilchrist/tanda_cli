module Tanda::CLI
  module CLI::Commands
    class ClockIn
      def initialize(@client : API::Client, @clock_type : String); end

      def execute
        now = Utils::Time.now
        error = client.send_clockin(now, clock_type)

        if error
          Utils::Display.error(error)
        else
          display_success_message
        end
      end

      private getter client
      private getter clock_type

      private def display_success_message
        success_message = case clock_type
        when "start"
          "You are now clocked in!"
        when "finish"
          "You are now clocked out!"
        when "break_start"
          "Your break has started!"
        when "break_finish"
          "Your break has ended!"
        end

        if success_message
          Utils::Display.success("#{success_message} (#{Current.user.id})")
        end
      end
    end
  end
end
