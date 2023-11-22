require "json"
require "file_utils"

require "./configuration/**"
require "./error/invalid_start_of_week"
require "./types/access_token"
require "./utils/url"

module TandaCLI
  class Configuration
    include JSON::Serializable
    include Configuration::Macros

    CONFIG_DIR  = "#{Path.home}/.tanda_cli"
    CONFIG_PATH = "#{CONFIG_DIR}/config.json"

    PRODUCTION = "production"
    STAGING    = "staging"

    def self.init : Configuration
      return new unless File.exists?(CONFIG_PATH)

      File.open(CONFIG_PATH) do |file|
        config_contents = file.gets_to_end
        from_json(config_contents)
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

    def initialize(
      @clockin_photo_path : String? = nil,
      @production : Environment = Environment.new,
      @staging : Environment = Environment.new,
      @mode : String = PRODUCTION,
      @start_of_week : Time::DayOfWeek = Time::DayOfWeek::Monday,
      @treat_paid_breaks_as_unpaid : Bool? = false
    ); end

    getter start_of_week
    property clockin_photo_path : String?
    property mode : String

    # Secret manual configuration options
    # TODO: Remove this - currently to get around annoying issue where breaks get marked as paid which doesn't work for my needs
    @[JSON::Field(emit_null: true)]
    getter? treat_paid_breaks_as_unpaid : Bool?

    # properties that are delegated based on the current environment
    environment_property time_zone : String?
    environment_property organisations : Array(Organisation)
    environment_property site_prefix : String
    environment_property access_token : AccessToken

    delegate clear_access_token!, current_organisation!, to: current_environment

    def current_environment : Environment
      staging? ? @staging : @production
    end

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

    def reset_environment!
      if staging?
        reset_staging!
      else
        reset_production!
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
      File.write(CONFIG_PATH, content: to_json)
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

    private def create_config_dir_if_not_exists!
      FileUtils.mkdir_p(CONFIG_DIR) unless File.directory?(CONFIG_DIR)
    end
  end
end
