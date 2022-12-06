require "json"
require "./me/organisation"

module Tanda::CLI
  module Types
    class Me
      include JSON::Serializable

      getter name : String
      getter email : String
      getter country : String
      getter time_zone : String
      getter user_ids : Array(Int32)
      getter permissions : Array(String)
      getter organisations : Array(Me::Organisation)
    end
  end
end
