require "json"

module Tanda::CLI
  module Types
    abstract class Base
      include JSON::Serializable
    end
  end
end
