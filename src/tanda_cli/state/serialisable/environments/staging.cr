module TandaCLI
  class State
    class Serialisable
      module Environments
        class Staging
          include JSON::Serializable

          def initialize(
            @region : Region = Region::APAC,
            @access_token : AccessToken? = nil,
            @organisations : Array(Organisation) = Array(Organisation).new,
          ) : Nil; end

          property region : Region
          property access_token : AccessToken?
          property organisations : Array(Organisation) = Array(Organisation).new

          def base_url : String
            "https://#{region.staging_host}"
          end

          def oauth_url(endpoint : State::OAuthEndpoint) : String
            endpoint.url(base_url)
          end

          def auth_candidates : Array(AuthCandidate)
            Region.values.reject(&.internal?).map do |region|
              AuthCandidate.new("https://#{region.staging_host}", region.display_name) { self.region = region }
            end
          end

          def current_organisation? : Organisation?
            @organisations.find(&.current?)
          end

          def redacted : Staging
            Staging.new(
              region: @region,
              access_token: @access_token.try(&.redacted),
              organisations: @organisations,
            )
          end

          def display_label : String
            "Staging"
          end
        end
      end
    end
  end
end
