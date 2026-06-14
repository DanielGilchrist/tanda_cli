require "json"

require "../../error/interface"

module TandaCLI
  module API
    module Types
      struct Error
        include TandaCLI::Error::Interface
        include JSON::Serializable

        getter error : String
        getter error_description : String?
      end
    end
  end
end
