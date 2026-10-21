require "json"

require "./updatable"

module TandaCLI
  module API
    module Types
      class ShiftUpdate
        include JSON::Serializable
        include Updatable

        update_field start : Time, converter: Time::EpochConverter
        update_field finish : Time, converter: Time::EpochConverter

        def initialize : Nil; end
      end
    end
  end
end
