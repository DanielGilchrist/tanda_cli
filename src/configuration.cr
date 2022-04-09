require "json"

module Tanda::CLI
  class Configuration
    CONFIG_PATH = "/home/daniel/.tanda_cli/config.json"
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
      file = File.new(CONFIG_PATH)
      content = file.gets_to_end
      @config = Config.from_json(content)

      file.close
    end

    def token! : String
      token = access_token.token
      raise "Token is missing" if token.nil?

      token
    end

    def save!
      File.write(CONFIG_PATH, config.to_json)
    end

    def get_api_url : String
      "https://#{site_prefix}.tanda.co/api/v2"
    end

    private getter config : Config
  end
end
