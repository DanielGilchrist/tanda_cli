module TandaCLI
  module Commands
    class ClockIn
      class Display < Commands::Base
        required_scopes :device

        def setup_
          @name = "display"
          @summary = @description = "Display current clockins"
        end

        def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
          now = Utils::Time.now
          clockins = client.clockins(current.user.id, now).or { |error| display.error!(error) }.sort_by(&.time)
          return stdout.puts "You aren't currently clocked in" if clockins.empty?

          stdout.puts "Clock ins for today"
          clockins.each do |clockin|
            Representers::ClockIn.new(clockin).display(stdout)
          end
        end
      end
    end
  end
end
