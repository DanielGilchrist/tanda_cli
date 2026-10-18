require "./environment"

module TandaCLI
  module Storage
    module Legacy
      struct Document
        include JSON::Serializable

        def self.parse?(contents : String) : Document?
          from_json(contents)
        rescue JSON::Error
          nil
        end

        getter clockin_photo_path : String?
        getter production : Environment?
        getter staging : Environment?
        getter custom : Environment?
        getter current_environment : ::TandaCLI::Environment = ::TandaCLI::Environment::Production
        getter start_of_week : Time::DayOfWeek = Time::DayOfWeek::Monday

        @[JSON::Field(key: "treat_paid_breaks_as_unpaid")]
        getter? treat_paid_breaks_as_unpaid : Bool = false

        def configuration(environment : ::TandaCLI::Environment) : Configuration::Serialisable
          section =
            case environment
            in .production?
              production
            in .staging?
              staging
            in .custom?
              custom
            end

          Configuration::Serialisable.new(
            clockin_photo_path: clockin_photo_path,
            start_of_week: start_of_week,
            treat_paid_breaks_as_unpaid: treat_paid_breaks_as_unpaid?,
            regular_hours: section.try(&.regular_hours) || Models::RegularHoursByOrganisation.new,
          )
        end

        def state : State::Serialisable
          custom_url = custom.try(&.url)

          State::Serialisable.new(
            production: State::Serialisable::Environments::Production.new(
              region: production.try(&.region) || Region::APAC,
              access_token: production.try(&.access_token),
              organisations: organisations(production),
            ),
            staging: State::Serialisable::Environments::Staging.new(
              region: staging.try(&.region) || Region::APAC,
              access_token: staging.try(&.access_token),
              organisations: organisations(staging),
            ),
            custom: custom_url && State::Serialisable::Environments::Custom.new(
              url: custom_url,
              access_token: custom.try(&.access_token),
              organisations: organisations(custom),
            ),
            current_environment: current_environment,
          )
        end

        private def organisations(environment : Environment?) : Array(State::Serialisable::Organisation)
          environment.try(&.organisations.map(&.to_state)) || Array(State::Serialisable::Organisation).new
        end
      end
    end
  end
end
