require "./photo/*"

module TandaCLI
  module Commands
    struct ClockIn
      @[Kebab::Command(name: "photo", summary: "View, set or clear clockin photo to be used by default")]
      struct Photo
        include Kebab::Serialisable

        @[Kebab::Subcommand]
        getter command : Clear | List | Set | View | Nil

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
