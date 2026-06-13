require "./break/*"

module TandaCLI
  module Commands
    struct ClockIn
      @[Kebab::Command(summary: "Clock a break")]
      struct Break
        include Kebab::Parseable

        @[Kebab::Subcommand]
        getter command : Start | Finish
      end
    end
  end
end
