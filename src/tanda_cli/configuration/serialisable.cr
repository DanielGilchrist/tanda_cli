module TandaCLI
  class Configuration
    class Serialisable
      include JSON::Serializable

      def initialize(
        @clockin_photo_path : String? = nil,
        @production : Environment::Production = Environment::Production.new,
        @staging : Environment::Staging = Environment::Staging.new,
        @custom : Environment::Custom? = nil,
        @current_environment : Environment::Name = Environment::Name::Production,
        @start_of_week : Time::DayOfWeek = Time::DayOfWeek::Monday,
        @treat_paid_breaks_as_unpaid : Bool = false,
      ); end

      property clockin_photo_path : String?
      property start_of_week : Time::DayOfWeek = Time::DayOfWeek::Monday

      @[JSON::Field(emit_null: true)]
      property? treat_paid_breaks_as_unpaid : Bool = false

      @production : Environment::Production = Environment::Production.new
      @staging : Environment::Staging = Environment::Staging.new
      @custom : Environment::Custom? = nil
      @current_environment : Environment::Name = Environment::Name::Production

      def pretty_start_of_week : String
        @start_of_week.to_s
      end

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

      def reset_current_environment! : Nil
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
    end
  end
end
