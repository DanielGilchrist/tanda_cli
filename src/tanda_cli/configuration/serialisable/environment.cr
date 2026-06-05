module TandaCLI
  class Configuration
    class Serialisable
      module Environment
        alias Any = Production | Staging | Custom

        struct AuthCandidate
          getter base_url : String
          getter display_name : String

          def initialize(@base_url : String, @display_name : String, &on_selected : ->)
            @on_selected = on_selected
          end

          def initialize(@base_url : String, @display_name : String)
            @on_selected = -> { }
          end

          def oauth_url(endpoint : Configuration::OAuthEndpoint) : String
            endpoint.url(@base_url)
          end

          def selected! : Nil
            @on_selected.call
          end
        end

        enum Name
          Production
          Staging
          Custom

          def to_json(builder : JSON::Builder) : Nil
            builder.string(to_s.downcase)
          end
        end
      end
    end
  end
end
