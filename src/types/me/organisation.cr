require "json"

module Tanda::CLI
  module Types
    class Me
      class Organisation
        include JSON::Serializable

        getter id : Int32
        getter name : String
        getter locale : String
        getter country : String
        getter user_id : Int32
      end
    end
  end
end
