require "json"
require "file_utils"

require "./configuration/**"
require "./types/access_token"

module Tanda::CLI
  class Configuration
    include Configuration::Macros

    CONFIG_DIR  = "#{Path.home}/.tanda_cli"
    CONFIG_PATH = "#{CONFIG_DIR}/config.json"

    DEFAULT_SITE_PREFIX = "eu"

    VALID_HOSTS = [
      ".tanda.co",
      ".workforce.com"
    ]

    alias ErrorString = String

    class Organisation
      include JSON::Serializable

      # defaults
      @current : Bool = false

      @[JSON::Field(key: "id")]
      getter id : Int32

      @[JSON::Field(key: "name")]
      getter name : String

      @[JSON::Field(key: "user_id")]
      getter user_id : Int32

      @[JSON::Field(key: "current")]
      property current : Bool

      def current? : Bool
        current
      end
    end

    class AccessToken
      include JSON::Serializable

      # defaults
      @email      : String? = nil
      @token      : String? = nil
      @token_type : String? = nil
      @scope      : String? = nil
      @created_at : Int32?  = nil

      # Allows initialization with default values
      # i.e. `Config.new` vs `Config.from_json(%({}))`
      def self.new
        super
      end

      @[JSON::Field(key: "email")]
      property email : String?

      @[JSON::Field(key: "token")]
      property token : String?

      @[JSON::Field(key: "token_type")]
      property token_type : String?

      @[JSON::Field(key: "scope")]
      property scope : String?

      @[JSON::Field(key: "created_at")]
      property created_at : Int32?
    end

    class Environment
      include JSON::Serializable

      # defaults
      @site_prefix   : String              = DEFAULT_SITE_PREFIX
      @access_token  : AccessToken         = AccessToken.new
      @organisations : Array(Organisation) = [] of Organisation

      # Allows initialization with default values
      # i.e. `Config.new` vs `Config.from_json(%({}))`
      def self.new
        super
      end

      @[JSON::Field(key: "site_prefix")]
      property site_prefix : String

      @[JSON::Field(key: "access_token")]
      property access_token : AccessToken

      @[JSON::Field(key: "organisations")]
      property organisations : Array(Organisation)

      @[JSON::Field(key: "time_zone")]
      property time_zone : String?
    end

    class Config
      include JSON::Serializable

      # defaults
      @production : Environment = Environment.new
      @staging    : Environment = Environment.new
      @mode       : String      = "production"

      # Allows initialization with default values
      # i.e. `Config.new` vs `Config.from_json(%({}))`
      def self.new
        super
      end

      @[JSON::Field(key: "production")]
      getter production

      @[JSON::Field(key: "staging")]
      getter staging

      @[JSON::Field(key: "mode")]
      property mode : String

      def reset_staging!
        @staging = Environment.new
      end

      def reset_production!
        @production = Environment.new
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

    def self.validate_url(url : String) : URI | ErrorString
      uri = URI.parse(url).normalize!
      return "Invalid URL" if uri.opaque?
      return "URL must be prefixed with \"https://\"" if uri.scheme != "https"
      return "URL cannot contain query parameters" if uri.query

      host = uri.host
      doesnt_contain_valid_host = host && VALID_HOSTS.none? { |valid_host| host.includes?(valid_host) }
      return "Host must contain #{VALID_HOSTS.join(" or ")}" if doesnt_contain_valid_host

      uri
    end

    def initialize(@config : Config = Config.new); end

    delegate mode, to: config

    # properties that return from a different environment depending on `mode`
    mode_property time_zone     : String?
    mode_property organisations : Array(Organisation)
    mode_property site_prefix   : String
    mode_property access_token  : AccessToken

    def staging? : Bool
      mode != "production"
    end

    def reset_environment!
      if staging?
        config.reset_staging!
      else
        config.reset_production!
      end
    end

    def mode=(value : String)
      config.mode = value
    end

    def token! : String
      token = access_token.token
      Utils::Display.fatal!("Token is missing") if token.nil?

      token
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

    def get_api_url : String
      case mode
      when "production"
        "https://#{site_prefix}.tanda.co/api/v2"
      when "staging"
        prefix = "#{site_prefix}." if site_prefix != "my"
        "https://staging.#{prefix}tanda.co/api/v2"
      else
        validated_uri = self.class.validate_url(mode)

        custom_uri = if validated_uri.is_a?(String)
          Utils::Display.error!(validated_uri, mode)
        else
          validated_uri.to_s
        end

        "#{custom_uri}/api/v2"
      end
    end

    private getter config : Config

    private def create_config_dir_if_not_exists!
      FileUtils.mkdir_p(CONFIG_DIR) unless File.directory?(CONFIG_DIR)
    end
  end
end
