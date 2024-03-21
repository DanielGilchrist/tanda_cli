module TandaCLI
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

      module ScopeConverter
        def self.from_json(value : JSON::PullParser) : Array(API::Scope)
          scopes_string = value.read_string_or_null
          return API::Scope.values if scopes_string.nil?

          scopes_string.split(" ").compact_map(&->API::Scope.parse?(String))
        end

        def self.to_json(value, json_builder : JSON::Builder)
          json_builder.string(value.map(&.to_api_name).join(" "))
        end
      end

      property email : String?
      property token : String?
      property token_type : String?

      @[JSON::Field(converter: TandaCLI::Configuration::AccessToken::ScopeConverter)]
      property scope : Array(API::Scope)?

      property created_at : Int32?
    end
  end
end
