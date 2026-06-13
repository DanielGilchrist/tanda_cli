module TandaCLI
  module Commands
    struct RegularHours
      @[Kebab::Command(summary: "Clear regular hours for the current user")]
      struct Clear
        include Kebab::Parseable

        def run(context : Context) : Nil
          display = context.display
          input = context.input
          organisation = context.config.current_organisation!

          input.request_and("Are you sure you want to clear regular hours for #{organisation.name}? (y/n)", :warning) do |user_input|
            return if user_input != "y"
          end

          organisation.clear_regular_hours_schedules!
          context.config.save!

          display.success("Regular hours cleared for #{organisation.name}.")
        end
      end
    end
  end
end
