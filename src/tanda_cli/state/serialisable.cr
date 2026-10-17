require "json"

require "./serialisable/*"

module TandaCLI
  class State
    class Serialisable
      include JSON::Serializable

      def self.parse?(contents : String) : Serialisable?
        from_json(contents)
      rescue JSON::Error
        nil
      end

      def initialize(
        @production : Environment::Production = Environment::Production.new,
        @staging : Environment::Staging = Environment::Staging.new,
        @custom : Environment::Custom? = nil,
        @current_environment : Environment::Name = Environment::Name::Production,
      ) : Nil; end

      @production : Environment::Production = Environment::Production.new
      @staging : Environment::Staging = Environment::Staging.new
      @custom : Environment::Custom? = nil

      getter current_environment : Environment::Name = Environment::Name::Production

      def current : Environment::Any
        case @current_environment
        in .production?
          @production
        in .staging?
          @staging
        in .custom?
          @custom || raise("Custom environment selected but not configured")
        end
      end

      def use_production! : Nil
        @current_environment = Environment::Name::Production
      end

      def use_staging! : Nil
        @current_environment = Environment::Name::Staging
      end

      def use_custom!(url : URI) : Nil
        existing = @custom
        if existing.nil? || existing.url != url
          @custom = Environment::Custom.new(url: url)
        end
        @current_environment = Environment::Name::Custom
      end

      def clear_current! : Nil
        case @current_environment
        in .production?
          @production = Environment::Production.new
        in .staging?
          @staging = Environment::Staging.new
        in .custom?
          existing = @custom
          @custom = existing && Environment::Custom.new(existing.url)
        end
      end

      def redacted : Serialisable
        Serialisable.new(
          production: @production.redacted,
          staging: @staging.redacted,
          custom: @custom.try(&.redacted),
          current_environment: @current_environment,
        )
      end
    end
  end
end
