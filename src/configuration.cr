require "json"
require "file_utils"

require "./types/access_token"

module Tanda::CLI
  class Configuration
    DEFAULT_CONFIG = {
      "site_prefix": "eu",
      "access_token": {
        "email": nil,
        "token": nil,
        "token_type": nil,
        "scope": nil,
        "created_at": nil
      }
    }.to_json

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

      @[JSON::Field(key: "site_prefix")]
      property site_prefix : String

      @[JSON::Field(key: "access_token")]
      property access_token : AccessToken
    end

    def initialize
      @config = Config.from_json(DEFAULT_CONFIG)
    end

    delegate site_prefix, access_token, to: config

    def site_prefix=(value : String)
      config.site_prefix = value
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
