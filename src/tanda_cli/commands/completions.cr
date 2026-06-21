require "kebab"

module TandaCLI
  module Commands
    @[Kebab::Command(summary: "Print a shell completion script")]
    struct Completions
      include Kebab::Parseable

      @[Kebab::Argument(description: "Shell", converter: Kebab::Convert::Enum(Kebab::Completion::Shell))]
      getter shell : Kebab::Completion::Shell

      def run(context : Context) : Nil
        context.display.puts(shell.generate(Main.schema))
      end
    end
  end
end
