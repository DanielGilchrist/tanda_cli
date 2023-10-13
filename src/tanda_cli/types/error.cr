require "json"

module TandaCLI
  module Types
    class Error
      include TandaCLI::Error::Interface
      include JSON::Serializable
    end
  end
end
