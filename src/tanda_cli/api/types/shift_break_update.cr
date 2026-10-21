require "json"

require "./updatable"

module TandaCLI
  module API
    module Types
      class ShiftBreakUpdate
        include JSON::Serializable
        include Updatable

        update_field start : Time, converter: Time::EpochConverter
        update_field finish : Time, converter: Time::EpochConverter
        update_field length : Int32

        def initialize : Nil; end
      end
    end
  end
end
