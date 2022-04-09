require "json"
require "./organisation"

module Tanda::CLI
  module Types
    class Me::Core
      include JSON::Serializable

      @[JSON::Field(key: "name")]
      property name : String

      @[JSON::Field(key: "email")]
      property email : String

      @[JSON::Field(key: "user_ids")]
      property user_ids : Array(Int32)

      @[JSON::Field(key: "organisations")]
      property organisations : Array(Me::Organisation)
    end
  end
end
