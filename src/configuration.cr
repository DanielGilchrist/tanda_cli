require "json"

module Tanda::CLI
  class Configuration
    # DEFAULT_CONFIG = {
    #   "site_prefix": "eu",
    #   "access_token": {
    #     "token": nil,
    #     "token_type": nil,
    #     "scope": nil,
    #     "created_at": nil
    #   }
    # }.to_json

    class AccessToken
      include JSON::Serializable

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
      @config = parse_config!
    end

    delegate site_prefix, access_token, to: config

    def get_api_url : String
      "https://#{site_prefix}.tanda.co/api/v2"
    end

    private getter config : Config

    private def parse_config! : Config
      file = File.new("/home/daniel/.tanda_cli/config.json")
      content = file.gets_to_end
      parsed_config = Config.from_json(content)

      file.close

      parsed_config
    end
  end
end
