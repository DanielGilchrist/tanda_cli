module TandaCLI
  module Commands
    struct StartOfWeek
      @[Kebab::Command(summary: "Display the currently set start of the week")]
      struct Display
        include Kebab::Parseable

        def run(context : Context) : Nil
          context.display.puts "#{context.config.pretty_start_of_week.colorize.white.bold}"
        end
      end
    end
  end
end
