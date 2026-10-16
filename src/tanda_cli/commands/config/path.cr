module TandaCLI
  module Commands
    struct Config
      @[Kebab::Command(summary: "Print the path to the configuration file")]
      struct Path
        include Kebab::Parseable

        def run(context : Context) : Nil
          context.display.puts(context.config_file.path)
        end
      end
    end
  end
end
