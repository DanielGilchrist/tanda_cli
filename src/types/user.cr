require "json"
require "./user/regular_hours"

module Tanda::CLI
  module Types
    class User
      include JSON::Serializable

      getter id : Int32
      getter name : String

      @[JSON::Field(emit_null: true)]
      getter regular_hours : User::RegularHours?
    end
  end
end
