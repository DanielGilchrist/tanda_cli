module TandaCLI
  class Configuration
    class Serialisable
      module Environment
        class Staging
          include JSON::Serializable

          def initialize(
            @region : Region = Region::APAC,
            @access_token : AccessToken? = nil,
            @organisations : Array(Organisation) = Array(Organisation).new,
          ); end

          property region : Region
          property access_token : AccessToken?
          property organisations : Array(Organisation)

          def base_url : String
            "https://#{region.staging_host}"
          end

          def display_label : String
            "Staging"
          end

          def current_organisation? : Organisation?
            @organisations.find(&.current?)
          end

          def current_organisation! : Organisation
            current_organisation? || raise("No current organisation set!")
          end
        end
      end
    end
  end
end
