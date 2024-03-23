require "json"

module TandaCLI
  module Types
    module Converters
      module ScopeConverter
        def self.from_json(value : JSON::PullParser) : Array(Scopes::Scope)
          scopes_string = value.read_string_or_null
          return Scopes::Scope.values if scopes_string.nil?

          scopes_string.split(" ").compact_map(&->Scopes::Scope.parse?(String))
        end

        def self.to_json(value, json_builder : JSON::Builder)
          json_builder.string(Scopes.join_to_api_string(value))
        end
      end
    end
  end
end
