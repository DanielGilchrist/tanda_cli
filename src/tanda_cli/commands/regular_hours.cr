require "../../../kebab/src/kebab"
require "./regular_hours/*"

module TandaCLI
  module Commands
    @[Kebab::Command(summary: "View or set your regular hours")]
    struct RegularHours
      include Kebab::Parseable

      @[Kebab::Subcommand]
      getter command : Determine | Display | Clear
    end
  end
end
