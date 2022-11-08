require "json"
require "file_utils"

require "./types/access_token"

module Tanda::CLI
  class Configuration
    DEFAULT_SITE_PREFIX = "eu"

    DEFAULT_ACCESS_TOKEN = %({
      "email": null,
      "token": null,
      "token_type": null,
      "scope": null,
      "created_at": null
    })

    DEFAULT_ORGANISATIONS = %([])

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
      @access_token  : AccessToken         = AccessToken.from_json(DEFAULT_ACCESS_TOKEN)
      @organisations : Array(Organisation) = Array(Organisation).from_json(DEFAULT_ORGANISATIONS)

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
      @production : Environment = Environment.from_json(%({}))
      @staging    : Environment = Environment.from_json(%({}))
      @mode       : String      = "production"

      @[JSON::Field(key: "production")]
      getter production

      @[JSON::Field(key: "staging")]
      getter staging

      @[JSON::Field(key: "mode")]
      property mode : String
    end

    def self.validate_url(url : String) : URI | ErrorString
      uri = URI.parse(url).normalize!
      return "Invalid URL" if uri.opaque?
      return "URL cannot contain query parameters" if uri.query

      host = uri.host
      doesnt_contain_valid_host = host && VALID_HOSTS.none? { |valid_host| host.includes?(valid_host) }
      return "Host must contain #{VALID_HOSTS.join(" or ")}" if doesnt_contain_valid_host

      uri
    end

    def initialize
      @config = Config.from_json(%({}))
    end

    delegate mode, to: config

    def staging? : Bool
      mode != "production"
    end

    def time_zone
      if staging?
        config.staging.time_zone
      else
        config.production.time_zone
      end
    end

    def organisations : Array(Organisation)
      if staging?
        config.staging.organisations
      else
        config.production.organisations
      end
    end

    def site_prefix : String
      if staging?
        config.staging.site_prefix
      else
        config.production.site_prefix
      end
    end

    def access_token : AccessToken
      if staging?
        config.staging.access_token
      else
        config.production.access_token
      end
    end

    def access_token=(value : AccessToken)
      if staging?
        config.staging_access_token = value
      else
        config.access_token = value
      end
    end

    def site_prefix=(value : String)
      if staging?
        config.staging.site_prefix = value
      else
        config.production.site_prefix = value
      end
    end

    def organisations=(value : Array(Organisation))
      if staging?
        config.staging.organisations = value
      else
        config.production.organisations = value
      end
    end

    def time_zone=(value : String)
      if staging?
        config.staging.time_zone = value
      else
        config.production.time_zone = value
      end
    end

    def mode=(value : String)
      config.mode = value
    end

    def parse_config!
      return unless File.exists?(config_path)

      file = File.new(config_path)
      content = file.gets_to_end
      @config = Config.from_json(content)
    ensure
      file.close if file
    end

    def token! : String
      token = access_token.token
      raise "Token is missing" if token.nil?

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
      File.write(config_path, content: config.to_json)
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
        if validated_uri.is_a?(String)
          Utils::Display.error(validated_uri, mode)
          exit
        else
          validated_uri.to_s
        end
      end
    end

    private getter config : Config

    private def config_dir : String
      @config_dir ||= "#{Path.home}/.tanda_cli"
    end

    private def config_path : String
      @config_path ||= "#{config_dir}/config.json"
    end

    private def create_config_dir_if_not_exists!
      FileUtils.mkdir_p(config_dir) unless File.directory?(config_dir)
    end
  end
end
