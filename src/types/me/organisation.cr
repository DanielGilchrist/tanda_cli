require "json"

module Tanda::CLI
  module Types
    class Me::Organisation
      include JSON::Serializable

      @[JSON::Field(key: "id")]
      property id : Int32

      @[JSON::Field(key: "name")]
      property name : String

      @[JSON::Field(key: "locale")]
      property locale : String

      @[JSON::Field(key: "country")]
      property country : String

      @[JSON::Field(key: "user_id")]
      property user_id : Int32
    end
  end
end
