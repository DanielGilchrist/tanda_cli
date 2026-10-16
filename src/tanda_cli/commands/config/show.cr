module TandaCLI
  module Commands
    struct Config
      @[Kebab::Command(summary: "Print the configuration with secrets redacted")]
      struct Show
        include Kebab::Parseable

        def run(context : Context) : Nil
          display = context.display
          path = context.config_file.path

          contents = context.config_file.read.presence
          return display.info("No configuration yet", path) if contents.nil?

          serialisable = Configuration::Serialisable.parse?(contents)
          display.error!("Invalid config!", path) if serialisable.nil?

          display.puts(serialisable.redacted.to_pretty_json)
        end
      end
    end
  end
end
