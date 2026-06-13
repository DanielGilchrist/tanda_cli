require "../../converters"

module TandaCLI
  module Commands
    struct ClockIn
      module Options
        @[Kebab::Option(short: 'p', description: "Specify a clockin photo (file path or specify photo name if directory has been set)")]
        getter photo : String?

        @[Kebab::Option(short: 's', description: "Skip clock in validations")]
        getter? skip_validations : Bool = false

        @[Kebab::Option(short: 'a', converter: ::TandaCLI::Converters::TimeOfDay, description: "Clock in at a past time (e.g. \"8:45\", \"5:30pm\", \"17:30\")")]
        getter at : Models::TimeOfDay?

        @[Kebab::Option(short: 'd', converter: ::TandaCLI::Converters::Day, description: "Date for --at, defaults to today (\"yesterday\" or YYYY-MM-DD)")]
        getter date : ::Time?
      end
    end
  end
end
