module Tanda::CLI
  module CLI::Executors
    class ClockIn
      class Display
        def initialize(@client : API::Client); end

        def execute
          now = Utils::Time.now
          clockins = @client.clockins(now).or(&.display!).sort_by(&.time)
          return puts "You aren't currently clocked in" if clockins.empty?

          puts "Clock ins for today"
          clockins.each do |clockin|
            Representers::ClockIn.new(clockin).display
          end
        end
      end
    end
  end
end
