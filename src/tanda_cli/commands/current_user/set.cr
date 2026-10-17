module TandaCLI
  module Commands
    struct CurrentUser
      @[Kebab::Command(summary: "Set the current user")]
      struct Set
        include Kebab::Parseable

        @[Kebab::Argument(description: "The ID of the user or name of the organisation to set as the current user")]
        getter id_or_name : String

        def run(context : Context) : Nil
          display = context.display
          state = context.state

          organisation =
            if user_id = id_or_name.to_i?
              state.organisations.find(&.user_id.==(user_id))
            else
              input_name = id_or_name.downcase
              state.organisations.find(&.name.downcase.includes?(input_name))
            end

          display.error!("Invalid argument", id_or_name) if organisation.nil?

          state.organisations.each(&.current = false)
          organisation.current = true
          state.save!

          display.success("The current user has been set to", format_organisation(organisation))
        end

        private def format_organisation(organisation : State::Serialisable::Organisation) : String
          "#{organisation.user_id} in #{organisation.name}"
        end
      end
    end
  end
end
