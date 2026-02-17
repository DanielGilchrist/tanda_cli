module TandaCLI
  class Configuration
    class Serialisable
      class AccessToken
        include JSON::Serializable

        def initialize(
          @email : String? = nil,
          @token : String? = nil,
          @token_type : String? = nil,
          @scopes : String? = nil,
          @created_at : Int32? = nil,
        ); end

        property email : String?
        property token : String?
        property token_type : String?
        property scopes : String?

        property created_at : Int32?

        def overwrite!(email : String, access_token : Types::AccessToken)
          self.email = email
          self.token = access_token.token
          self.token_type = access_token.token_type
          self.scopes = access_token.scopes
          self.created_at = access_token.created_at
        end
      end
    end
  end
end
