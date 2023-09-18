require "../base"

module Tanda::CLI
  module CLI::Commands
    class StartOfWeek
      class Set < Base
        def on_setup
          @name = "set"
          @summary = @description = "Set the start of the week"

          add_argument "day", description: "The day to set the start of the week to", required: true
        end

        def run(arguments : Cling::Arguments, options : Cling::Options) : Nil
          day = arguments.get("day").as_s
          config = Current.config

          if parse_error = config.set_start_of_week(day)
            Utils::Display.error!(parse_error)
          else
            config.save!
            Utils::Display.success("Start of the week set to #{config.pretty_start_of_week}")
          end
        end
      end
    end
  end
end
