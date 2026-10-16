require "kebab"
require "./config/*"

module TandaCLI
  module Commands
    @[Kebab::Command(summary: "Show where the configuration lives or what it contains")]
    struct Config
      include Kebab::Parseable

      @[Kebab::Subcommand]
      getter command : Path | Show
    end
  end
end
