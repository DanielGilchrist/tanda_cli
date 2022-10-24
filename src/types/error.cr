require "./base"

module Tanda::CLI
  module Types
    class Error < Base
      @[JSON::Field(key: "error")]
      getter error : String

      @[JSON::Field(key: "error_description")]
      getter error_description : String
    end
  end
end