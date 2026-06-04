require "json"

module TandaCLI
  module API
    module Types
      struct Error
        include TandaCLI::Error::Interface
        include JSON::Serializable
      end
    end
  end
end
