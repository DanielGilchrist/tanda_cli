require "../../../kebab/src/kebab"
require "./start_of_week/*"

module TandaCLI
  module Commands
    @[Kebab::Command(summary: "Set the start of the week (e.g. monday/sunday)")]
    struct StartOfWeek
      include Kebab::Parseable

      @[Kebab::Subcommand]
      getter command : Display | Set
    end
  end
end
