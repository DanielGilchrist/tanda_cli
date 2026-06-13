require "../../../kebab/src/kebab"
require "./mode/*"

module TandaCLI
  module Commands
    @[Kebab::Command(summary: "Set the mode to run commands in (production/staging/custom <url>)")]
    struct Mode
      include Kebab::Parseable

      @[Kebab::Subcommand]
      getter command : Production | Staging | Custom | Display
    end
  end
end
