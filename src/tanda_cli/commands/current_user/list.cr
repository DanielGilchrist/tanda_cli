module TandaCLI
  module Commands
    struct CurrentUser
      @[Kebab::Command(summary: "List available current users")]
      struct List
        include Kebab::Parseable

        def run(context : Context) : Nil
          display = context.display

          context.config.organisations.each do |organisation|
            current = organisation.current? ? " #{"(current)".colorize.green}" : ""
            display.puts "#{organisation.name.colorize.white.bold}#{current}"
            display.puts "User ID: #{organisation.user_id}\n\n"
          end
        end
      end
    end
  end
end
