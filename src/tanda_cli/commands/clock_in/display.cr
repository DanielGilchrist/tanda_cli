module TandaCLI
  module Commands
    struct ClockIn
      @[Kebab::Command(summary: "Display current clockins")]
      struct Display
        include Kebab::Parseable

        def run(context : Context) : Nil
          display = context.display

          now = Utils::Time.now
          clockins = context.client.clock_ins.list(context.current.user.id, now).or { |error| display.error!(error) }.sort_by(&.time)
          return display.puts "You aren't currently clocked in" if clockins.empty?

          display.puts "Clock ins for today"
          clockins.each do |clockin|
            Representers::ClockIn.new(clockin).display(display)
          end
        end
      end
    end
  end
end
