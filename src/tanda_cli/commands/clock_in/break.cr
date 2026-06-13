require "./break/*"

module TandaCLI
  module Commands
    struct ClockIn
      @[Kebab::Command(name: "break", summary: "Clock a break")]
      struct Break
        include Kebab::Serialisable

        @[Kebab::Subcommand]
        getter command : Start | Finish | Nil

        def run(context : Context) : Nil
          if command = @command
            command.run(context)
          else
            context.display.puts(__kebab_help_text)
          end
        end
      end
    end
  end
end
