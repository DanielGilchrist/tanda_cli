require "../base"

module TandaCLI
  module Commands
    class StartOfWeek
      class Set < Base
        def setup_
          @name = "set"
          @summary = @description = "Set the start of the week"

          add_argument "day", description: "The day to set the start of the week to", required: true
        end

        def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
          day = arguments.get("day").as_s
          parsed = Time::DayOfWeek.parse?(day)
          display.error!(Error::InvalidStartOfWeek.new(day)) if parsed.nil?

          config.start_of_week = parsed
          config.save!
          display.success("Start of the week set to #{config.pretty_start_of_week}")
        end
      end
    end
  end
end
