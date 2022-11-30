require "json"
require "./me/organisation"

module Tanda::CLI
  module Types
    class Me
      include JSON::Serializable

      @[JSON::Field(key: "name")]
      getter name : String

      @[JSON::Field(key: "email")]
      getter email : String

      @[JSON::Field(key: "country")]
      getter country : String

      @[JSON::Field(key: "time_zone")]
      getter time_zone : String

      @[JSON::Field(key: "user_ids")]
      getter user_ids : Array(Int32)

      @[JSON::Field(key: "permissions")]
      getter permissions : Array(String)

      @[JSON::Field(key: "organisations")]
      getter organisations : Array(Me::Organisation)
    end
  end
end
