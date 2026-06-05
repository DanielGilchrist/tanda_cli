module TandaCLI
  class Configuration
    class Serialisable
      module Environment
        class Production
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
            "https://#{region.production_host}"
          end

          def oauth_url(endpoint : Configuration::OAuthEndpoint) : String
            endpoint.url(base_url)
          end

          def auth_candidates : Array(AuthCandidate)
            Region.values.map do |region|
              AuthCandidate.new("https://#{region.production_host}", region.display_name) { self.region = region }
            end
          end

          def display_label : String
            "Production"
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
