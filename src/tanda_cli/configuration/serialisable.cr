module TandaCLI
  class Configuration
    class Serialisable
      include JSON::Serializable

      def initialize(
        @clockin_photo_path : String? = nil,
        @production : Environment = Environment.new,
        @staging : Environment = Environment.new,
        @mode : Mode::Any = Mode::Production.new,
        @start_of_week : Time::DayOfWeek = Time::DayOfWeek::Monday,
        @treat_paid_breaks_as_unpaid : Bool = false,
      ); end

      property clockin_photo_path : String?
      property production : Environment = Environment.new
      property staging : Environment = Environment.new

      @[JSON::Field(converter: TandaCLI::Configuration::Mode::Converter)]
      property mode : Mode::Any = Mode::Production.new

      property start_of_week : Time::DayOfWeek = Time::DayOfWeek::Monday

      @[JSON::Field(emit_null: true)]
      property? treat_paid_breaks_as_unpaid : Bool = false

      delegate :organisations, :organisations=, :region, :region=, :access_token, to: current_environment

      def pretty_start_of_week : String
        @start_of_week.to_s
      end

      def current_environment : Environment
        staging? ? @staging : @production
      end

      def staging? : Bool
        @mode.is_a?(Mode::Staging)
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
