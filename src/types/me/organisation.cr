require "../base"

module Tanda::CLI
  module Types
    module Me
      class Organisation < Base
        @[JSON::Field(key: "id")]
        getter id : Int32

        @[JSON::Field(key: "name")]
        getter name : String

        @[JSON::Field(key: "locale")]
        getter locale : String

        @[JSON::Field(key: "country")]
        getter country : String

        @[JSON::Field(key: "user_id")]
        getter user_id : Int32
      end
    end
  end
end
