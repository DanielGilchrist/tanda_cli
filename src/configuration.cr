require "json"
require "file_utils"

require "./configuration/**"
require "./error/invalid_start_of_week"
require "./types/access_token"
require "./utils/url"
require "./utils/mixins/pretty_times"

module Tanda::CLI
  class Configuration
    include Configuration::Macros

    CONFIG_DIR  = "#{Path.home}/.tanda_cli"
    CONFIG_PATH = "#{CONFIG_DIR}/config.json"

    DEFAULT_SITE_PREFIX = "eu"

    PRODUCTION = "production"
    STAGING    = "staging"

    class Organisation
      include JSON::Serializable

      def self.from(organisation : Types::Me::Organisation) : self
        new(
          organisation.id,
          organisation.name,
          organisation.user_id
        )
      end

      def self.from(me : Types::Me) : Array(self)
        me.organisations.map(&->from(Types::Me::Organisation))
      end

      def initialize(@id : Int32, @name : String, @user_id : Int32, @current : Bool = false); end

      getter id : Int32
      getter name : String
      getter user_id : Int32
      property? current : Bool

      @[JSON::Field(key: "regular_hours")]
      property regular_hours_schedules : Array(RegularHoursSchedule)?

      def set_regular_hours_from_roster!(schedules : Array(Types::Schedule))
        pp schedules.first.inspect
      end

      class RegularHoursSchedule
        include JSON::Serializable
        include Utils::Mixins::PrettyTimes

        TIME_STRING_FORMAT = "%H:%M"

        module DayConverter
          def self.from_json(value : JSON::PullParser) : Time::DayOfWeek
            day_string = value.read_string
            Time::DayOfWeek.parse?(day_string) || Utils::Display.fatal!("Invalid day of week: #{day_string}")
          end

          def self.to_json(value, json_builder : JSON::Builder)
            json_builder.string(value.to_s)
          end
        end

        class Break
          include JSON::Serializable
          include Utils::Mixins::PrettyTimes

          def initialize(@_start_time : String, @_finish_time : String); end

          def start_time : Time
            Time.parse(_start_time, TIME_STRING_FORMAT, Current.time_zone)
          end

          def finish_time : Time
            Time.parse(_finish_time, TIME_STRING_FORMAT, Current.time_zone)
          end

          def length : Time::Span
            finish_time - start_time
          end

          private getter _start_time : String
          private getter _finish_time : String
        end

        def initialize(
          @day_of_week : Time::DayOfWeek,
          @breaks : Array(Break) = Array(Break).new,
          @automatic_break_length : UInt16? = nil,
          start_time : (String | Time)? = nil,
          finish_time : (String | Time)? = nil
        )
          @_start_time = begin
            case start_time
            in String
              start_time
            in Time
              start_time.to_s(TIME_STRING_FORMAT)
            in NilClass
            end
          end

          @_finish_time = begin
            case finish_time
            in String
              finish_time
            in Time
              finish_time.to_s(TIME_STRING_FORMAT)
            in NilClass
            end
          end
        end

        @[JSON::Field(converter: Tanda::CLI::Configuration::Organisation::RegularHoursSchedule::DayConverter)]
        getter day_of_week : Time::DayOfWeek

        getter breaks : Array(Break)

        getter automatic_break_length : UInt16?

        def start_time : Time?
          start_time = _start_time
          Time.parse(start_time, TIME_STRING_FORMAT, Current.time_zone) if start_time
        end

        def finish_time : Time?
          finish_time = _finish_time
          Time.parse(finish_time, TIME_STRING_FORMAT, Current.time_zone) if finish_time
        end

        private getter _start_time : String?
        private getter _finish_time : String?
      end
    end

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

    class Environment
      include JSON::Serializable

      def initialize(
        @site_prefix : String = DEFAULT_SITE_PREFIX,
        @access_token : AccessToken = AccessToken.new,
        @organisations : Array(Organisation) = Array(Organisation).new,
        @time_zone : String? = nil
      ); end

      property site_prefix : String
      property access_token : AccessToken
      property organisations : Array(Organisation)
      property time_zone : String?

      def clear_access_token!
        @access_token = AccessToken.new
      end

      def current_organisation! : Organisation
        @organisations.find(&.current?) || Utils::Display.error!("No current organisation set!")
      end
    end

    class Config
      include JSON::Serializable

      def initialize(
        @clockin_photo_path : String? = nil,
        @production : Environment = Environment.new,
        @staging : Environment = Environment.new,
        @mode : String = PRODUCTION,
        @start_of_week : Time::DayOfWeek = Time::DayOfWeek::Monday,
        @treat_paid_breaks_as_unpaid : Bool? = false
      ); end

      getter production
      getter staging
      getter start_of_week
      property clockin_photo_path : String?
      property mode : String

      # Secret manual configuration options
      # TODO: Remove this - currently to get around annoying issue where breaks get marked as paid which doesn't work for my needs
      @[JSON::Field(emit_null: true)]
      getter? treat_paid_breaks_as_unpaid : Bool?

      def reset_staging!
        @staging = Environment.new
      end

      def reset_production!
        @production = Environment.new
      end

      def pretty_start_of_week : String
        @start_of_week.to_s
      end

      def set_start_of_week(value : String) : Error::InvalidStartOfWeek?
        start_of_week = Time::DayOfWeek.parse?(value)
        return Error::InvalidStartOfWeek.new(value) if start_of_week.nil?

        @start_of_week = start_of_week
        nil
      end

      def staging? : Bool
        mode != PRODUCTION
      end

      def current_environment : Environment
        staging? ? staging : production
      end
    end

    def self.init : Configuration
      return new unless File.exists?(CONFIG_PATH)

      File.open(CONFIG_PATH) do |file|
        config_contents = file.gets_to_end
        parsed_config = Config.from_json(config_contents)

        new(parsed_config)
      rescue error
        {% if flag?(:debug) %}
          raise(error)
        {% else %}
          reason = error.message.try(&.split("\n").first) if error.is_a?(JSON::SerializableError) || error.is_a?(JSON::ParseException)
          Utils::Display.error("Invalid Config!", reason) do |sub_errors|
            sub_errors << "If you want to try and fix the config manually press Ctrl+C to quit\n"
            sub_errors << "Press enter if you want to proceed with a default config (this will override the existing config)"
          end
          gets # don't proceed unless user wants us to
          nil
        {% end %}
      end || new
    end

    def initialize(@config : Config = Config.new); end

    delegate clockin_photo_path, :clockin_photo_path=, to: config
    delegate mode, :mode=, to: config
    delegate start_of_week,
      pretty_start_of_week,
      set_start_of_week,
      staging?,
      current_environment,
      treat_paid_breaks_as_unpaid?,
      to: config

    # properties that are delegated based on the current environment
    environment_property time_zone : String?
    environment_property organisations : Array(Organisation)
    environment_property site_prefix : String
    environment_property access_token : AccessToken

    def clear_access_token!
      if staging?
        config.staging.clear_access_token!
      else
        config.production.clear_access_token!
      end
    end

    def reset_environment!
      if staging?
        config.reset_staging!
      else
        config.reset_production!
      end
    end

    def overwrite!(site_prefix : String, email : String, access_token : Types::AccessToken)
      self.site_prefix = site_prefix
      self.access_token.email = email
      self.access_token.token = access_token.token
      self.access_token.token_type = access_token.token_type
      self.access_token.scope = access_token.scope
      self.access_token.created_at = access_token.created_at

      save!
    end

    def save!
      create_config_dir_if_not_exists!
      File.write(CONFIG_PATH, content: config.to_json)
    end

    def api_url : String
      case mode
      when PRODUCTION
        "https://#{site_prefix}.tanda.co/api/v2"
      when STAGING
        prefix = "#{site_prefix}." if site_prefix != "my"
        "https://staging.#{prefix}tanda.co/api/v2"
      else
        validated_uri = Utils::URL.validate(mode)
        Utils::Display.error!(validated_uri, mode) if validated_uri.is_a?(String)

        "#{validated_uri}/api/v2"
      end
    end

    private getter config : Config

    private def create_config_dir_if_not_exists!
      FileUtils.mkdir_p(CONFIG_DIR) unless File.directory?(CONFIG_DIR)
    end
  end
end
