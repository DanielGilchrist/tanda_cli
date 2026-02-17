module TandaCLI
  class Configuration
    class Serialisable
      include JSON::Serializable

      PRODUCTION = Configuration::PRODUCTION

      def initialize(
        @clockin_photo_path : String? = nil,
        @production : Environment = Environment.new,
        @staging : Environment = Environment.new,
        @mode : String = PRODUCTION,
        @start_of_week : Time::DayOfWeek = Time::DayOfWeek::Monday,
        @treat_paid_breaks_as_unpaid : Bool? = false,
      ); end

      getter start_of_week : Time::DayOfWeek = Time::DayOfWeek::Monday
      property clockin_photo_path : String?
      property production : Environment = Environment.new
      property staging : Environment = Environment.new
      property mode : String = "production"

      @[JSON::Field(emit_null: true)]
      property? treat_paid_breaks_as_unpaid : Bool?

      delegate :organisations, :organisations=, :region, :region=, :access_token, to: current_environment

      def start_of_week=(value : String) : Time::DayOfWeek | Error::InvalidStartOfWeek
        start_of_week = Time::DayOfWeek.parse?(value)
        return Error::InvalidStartOfWeek.new(value) if start_of_week.nil?

        @start_of_week = start_of_week
      end

      def pretty_start_of_week : String
        @start_of_week.to_s
      end

      def current_environment : Environment
        staging? ? @staging : @production
      end

      def staging? : Bool
        mode != PRODUCTION
      end

      def reset_environment!
        if staging?
          reset_staging!
        else
          reset_production!
        end
      end

      private def reset_staging!
        @staging = Environment.new
      end

      private def reset_production!
        @production = Environment.new
      end
    end
  end
end
