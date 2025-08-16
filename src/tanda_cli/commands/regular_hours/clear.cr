require "../base"

module TandaCLI
  module Commands
    class RegularHours
      class Clear < Base
        def setup_
          @name = "clear"
          @summary = @description = "Clear regular hours for the current user"
        end

        def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
          organisation = config.current_organisation!

          input.request_and("Are you sure you want to clear regular hours for #{organisation.name}? (y/n)", :warning) do |input|
            return if input != "y"
          end

          organisation.clear_regular_hours_schedules!
          config.save!

          display.success("Regular hours cleared for #{organisation.name}.")
        end
      end
    end
  end
end
