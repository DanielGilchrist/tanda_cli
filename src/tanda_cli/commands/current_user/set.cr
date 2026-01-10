module TandaCLI
  module Commands
    class CurrentUser
      class Set < Base
        def setup_
          @name = "set"
          @summary = @description = "Set the current user"

          add_argument "id_or_name",
            description: "The ID of the user or name of the organisation to set as the current user",
            required: true
        end

        def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
          id_or_name = arguments.get("id_or_name").as_s

          organisation = begin
            if user_id = id_or_name.to_i?
              config.organisations.find(&.user_id.==(user_id))
            else
              input_name = id_or_name.downcase
              config.organisations.find(&.name.downcase.includes?(input_name))
            end
          end

          display.error!("Invalid argument", id_or_name) if organisation.nil?

          config.organisations.each(&.current = false)
          organisation.current = true
          config.save!

          display.success("The current user has been set to", format_organisation(organisation))
        end

        private def format_organisation(organisation : Configuration::Serialisable::Organisation)
          "#{organisation.user_id} in #{organisation.name}"
        end
      end
    end
  end
end
