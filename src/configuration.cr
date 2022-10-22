require "json"
require "file_utils"

require "./types/access_token"

module Tanda::CLI
  class Configuration
    DEFAULT_SITE_PREFIX = "eu"

    DEFAULT_ACCESS_TOKEN = {
      "email": nil,
      "token": nil,
      "token_type": nil,
      "scope": nil,
      "created_at": nil
    }

    DEFAULT_ORGANISATIONS = [] of Organisation

    DEFAULT_CONFIG = {
      "site_prefix": DEFAULT_SITE_PREFIX,
      "access_token": DEFAULT_ACCESS_TOKEN,
      "organisations": DEFAULT_ORGANISATIONS
    }

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

    class Config
      include JSON::Serializable

      # defaults
      @site_prefix   : String              = DEFAULT_SITE_PREFIX
      @access_token  : AccessToken         = AccessToken.from_json(DEFAULT_ACCESS_TOKEN.to_json)
      @organisations : Array(Organisation) = Array(Organisation).from_json(DEFAULT_ORGANISATIONS.to_json)

      @[JSON::Field(key: "site_prefix")]
      property site_prefix : String

      @[JSON::Field(key: "access_token")]
      property access_token : AccessToken

      @[JSON::Field(key: "organisations")]
      property organisations : Array(Organisation)

      @[JSON::Field(key: "time_zone")]
      property time_zone : String?
    end

    def initialize
      @config = Config.from_json(DEFAULT_CONFIG.to_json)
    end

    delegate site_prefix, access_token, organisations, time_zone, to: config

    def site_prefix=(value : String)
      config.site_prefix = value
    end

    def organisations=(value : Array(Organisation))
      config.organisations = value
    end

    def time_zone=(value : String)
      config.time_zone = value
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
      "https://#{site_prefix}.tanda.co/api/v2"
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
