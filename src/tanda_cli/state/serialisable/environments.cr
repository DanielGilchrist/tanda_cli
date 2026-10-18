module TandaCLI
  class State
    class Serialisable
      module Environments
        alias Any = Production | Staging | Custom

        struct AuthCandidate
          getter base_url : String
          getter display_name : String

          def initialize(@base_url : String, @display_name : String, &on_selected : ->) : Nil
            @on_selected = on_selected
          end

          def initialize(@base_url : String, @display_name : String) : Nil
            @on_selected = -> : Nil { }
          end

          def oauth_url(endpoint : State::OAuthEndpoint) : String
            endpoint.url(@base_url)
          end

          def selected! : Nil
            @on_selected.call
          end
        end
      end
    end
  end
end
