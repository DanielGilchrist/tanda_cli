require "json"

module TandaCLI
  module Types
    struct Error
      include TandaCLI::Error::Interface
      include JSON::Serializable
    end
  end
end
