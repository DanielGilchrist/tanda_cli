require "./target"

module TandaCLI
  module Commands
    struct Config
      @[Kebab::Command(summary: "Print the path to the config file for the current mode")]
      struct Path
        include Kebab::Parseable
        include Target

        def run(context : Context) : Nil
          context.display.puts(file(context).path)
        end
      end
    end
  end
end
