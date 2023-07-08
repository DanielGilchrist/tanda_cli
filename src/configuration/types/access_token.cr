module Tanda::CLI
  class Configuration
    class AccessToken
      include JSON::Serializable

      def initialize(
        @email : String? = nil,
        @token : String? = nil,
        @token_type : String? = nil,
        @scope : String? = nil,
        @created_at : Int32? = nil
      ); end

      property email : String?
      property token : String?
      property token_type : String?
      property scope : String?
      property created_at : Int32?
    end
  end
end
