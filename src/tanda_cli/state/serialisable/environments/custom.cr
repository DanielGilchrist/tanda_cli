module TandaCLI
  class State
    class Serialisable
      module Environments
        class Custom
          include JSON::Serializable

          module URIConverter
            extend self

            def from_json(value : JSON::PullParser) : URI
              URI.parse(value.read_string)
            end

            def to_json(value : URI, json_builder : JSON::Builder) : Nil
              json_builder.string(value.to_s)
            end
          end

          def initialize(
            @url : URI,
            @access_token : AccessToken? = nil,
            @organisations : Array(Organisation) = Array(Organisation).new,
          ) : Nil; end

          @[JSON::Field(converter: TandaCLI::State::Serialisable::Environments::Custom::URIConverter)]
          property url : URI

          property access_token : AccessToken?
          property organisations : Array(Organisation) = Array(Organisation).new

          def base_url : String
            url.to_s
          end

          def oauth_url(endpoint : State::OAuthEndpoint) : String
            endpoint.url(base_url)
          end

          def auth_candidates : Array(AuthCandidate)
            [AuthCandidate.new(base_url, base_url)]
          end

          def current_organisation? : Organisation?
            @organisations.find(&.current?)
          end

          def redacted : Custom
            Custom.new(
              url: @url,
              access_token: @access_token.try(&.redacted),
              organisations: @organisations,
            )
          end

          def display_label : String
            "Custom (#{url})"
          end
        end
      end
    end
  end
end
