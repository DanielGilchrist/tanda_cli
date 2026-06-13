module TandaCLI
  module Commands
    struct ClockIn
      module Options
        @[Kebab::Option(short: 'p', description: "Specify a clockin photo (file path or specify photo name if directory has been set)")]
        getter photo : String?

        @[Kebab::Option(short: 's', description: "Skip clock in validations")]
        getter? skip_validations : Bool = false

        @[Kebab::Option(short: 'a', description: "Clock in at a past time (e.g. \"8:45\", \"5:30pm\", \"17:30\")")]
        getter at : String?

        @[Kebab::Option(short: 'd', description: "Date for --at, defaults to today (\"yesterday\" or YYYY-MM-DD)")]
        getter date : String?
      end
    end
  end
end
