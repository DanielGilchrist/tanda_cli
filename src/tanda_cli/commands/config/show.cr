require "./target"

module TandaCLI
  module Commands
    struct Config
      @[Kebab::Command(summary: "Print the config in effect for the current mode")]
      struct Show
        include Kebab::Parseable
        include Target

        def run(context : Context) : Nil
          display = context.display
          file = file(context)

          contents = file.read.presence
          return display.info("Nothing stored yet", file.path) if contents.nil?

          document = parse(contents)
          display.error!("Invalid JSON!", file.path) if document.nil?

          display.puts(document.to_pretty_json)
        end

        private def parse(contents : String) : JSON::Serializable?
          return TandaCLI::State::Serialisable.parse?(contents).try(&.redacted) if state?

          Configuration::Serialisable.parse?(contents)
        end
      end
    end
  end
end
