module TandaCLI
  module Commands
    struct StartOfWeek
      @[Kebab::Command(summary: "Set the start of the week")]
      struct Set
        include Kebab::Parseable

        @[Kebab::Argument(description: "The day to set the start of the week to")]
        getter day : String

        def run(context : Context) : Nil
          display = context.display
          parsed = Time::DayOfWeek.parse?(day)
          display.error!(Error::InvalidStartOfWeek.new(day)) if parsed.nil?

          context.config.start_of_week = parsed
          context.config.save!
          display.success("Start of the week set to #{context.config.pretty_start_of_week}")
        end
      end
    end
  end
end
