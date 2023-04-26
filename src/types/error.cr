require "json"

module Tanda::CLI
  module Types
    class Error
      include Tanda::CLI::Error::Interface
      include JSON::Serializable
    end
  end
end
