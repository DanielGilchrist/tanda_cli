require "../../models/clock_in_day"

module TandaCLI
  module Commands
    module Helpers
      module ClockInDay
        private def resolve_day(context : Context) : ::Time
          clock_in_day = date
          return Utils::Time.now if clock_in_day.nil?

          case day = clock_in_day.on_or_before_today(context.config.start_of_week)
          in ::Time
            day
          in Error::FutureDate
            context.display.error!(day)
          end
        end

        private def confirm?(context : Context) : Bool
          answer = context.input.ask("Submit? (Y/n) ")
          answer.nil? || answer.downcase.in?("y", "yes")
        end
      end
    end
  end
end
