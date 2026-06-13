module TandaCLI
  module Commands
    struct CurrentUser
      @[Kebab::Command(summary: "Display the current user")]
      struct Display
        include Kebab::Parseable

        def run(context : Context) : Nil
          display = context.display

          if organisation = context.config.current_organisation?
            display.puts "#{organisation.name.colorize.white.bold} (User #{organisation.user_id})"
          else
            display.puts "A current user hasn't been set!"
          end
        end
      end
    end
  end
end
