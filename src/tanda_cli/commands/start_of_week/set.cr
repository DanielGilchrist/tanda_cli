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
          config = Current.config

          case parse_error = (config.start_of_week = day)
          in Error::InvalidStartOfWeek
            parse_error.display!
          in Time::DayOfWeek
            config.save!
            Utils::Display.success("Start of the week set to #{config.pretty_start_of_week}")
          end
        end
      end
    end
  end
end
