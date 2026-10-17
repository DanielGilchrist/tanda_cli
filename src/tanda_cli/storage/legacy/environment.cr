require "./organisation"

module TandaCLI
  module Storage
    module Legacy
      struct Environment
        include JSON::Serializable

        getter region : Region?

        @[JSON::Field(converter: TandaCLI::State::Serialisable::Environment::Custom::URIConverter)]
        getter url : URI?

        getter access_token : State::Serialisable::AccessToken?
        getter organisations : Array(Organisation) = Array(Organisation).new

        def regular_hours : Models::RegularHoursByOrganisation
          schedules = Models::RegularHoursByOrganisation.new

          organisations.each do |organisation|
            organisation_schedules = organisation.regular_hours_schedules
            next if organisation_schedules.nil? || organisation_schedules.empty?

            schedules[organisation.id] = organisation_schedules
          end

          schedules
        end
      end
    end
  end
end
