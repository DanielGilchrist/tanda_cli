require "./photo/*"

module TandaCLI
  module Commands
    struct ClockIn
      @[Kebab::Command(summary: "View, set or clear clockin photo to be used by default")]
      struct Photo
        include Kebab::Parseable

        @[Kebab::Subcommand]
        getter command : Clear | List | Set | View
      end
    end
  end
end
