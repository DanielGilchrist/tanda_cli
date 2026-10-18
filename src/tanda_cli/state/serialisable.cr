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
        @production : Environments::Production = Environments::Production.new,
        @staging : Environments::Staging = Environments::Staging.new,
        @custom : Environments::Custom? = nil,
        @current_environment : Environment = Environment::Production,
      ) : Nil; end

      @production : Environments::Production = Environments::Production.new
      @staging : Environments::Staging = Environments::Staging.new
      @custom : Environments::Custom? = nil

      getter current_environment : Environment = Environment::Production

      def current : Environments::Any
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
        @current_environment = Environment::Production
      end

      def use_staging! : Nil
        @current_environment = Environment::Staging
      end

      def use_custom!(url : URI) : Nil
        existing = @custom
        if existing.nil? || existing.url != url
          @custom = Environments::Custom.new(url: url)
        end
        @current_environment = Environment::Custom
      end

      def clear_current! : Nil
        case @current_environment
        in .production?
          @production = Environments::Production.new
        in .staging?
          @staging = Environments::Staging.new
        in .custom?
          existing = @custom
          @custom = existing && Environments::Custom.new(existing.url)
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
