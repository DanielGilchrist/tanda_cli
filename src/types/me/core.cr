require "json"
require "./organisation"

module Tanda::CLI
  module Types
    class Me::Core
      include JSON::Serializable

      @[JSON::Field(key: "name")]
      getter name : String

      @[JSON::Field(key: "email")]
      getter email : String

      @[JSON::Field(key: "user_ids")]
      getter user_ids : Array(Int32)

      @[JSON::Field(key: "organisations")]
      getter organisations : Array(Me::Organisation)
    end
  end
end
