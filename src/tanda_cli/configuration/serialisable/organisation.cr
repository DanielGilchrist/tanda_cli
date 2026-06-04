require "../../utils/mixins/pretty_times"

module TandaCLI
  class Configuration
    class Serialisable
      class Organisation
        include JSON::Serializable

        TIME_STRING_FORMAT = "%H:%M"

        def self.from(organisation : Types::Me::Organisation) : self
          new(
            organisation.id,
            organisation.name,
            organisation.user_id
          )
        end

        def self.from(me : Types::Me) : Array(self)
          me.organisations.map(&->from(Types::Me::Organisation))
        end

        def initialize(
          @id : Int32,
          @name : String,
          @user_id : Int32,
          @current : Bool = false,
          @_regular_hours_schedules : Array(RegularHoursSchedule)? = nil,
        ); end

        getter id : Int32
        getter name : String
        getter user_id : Int32
        property? current : Bool

        @[JSON::Field(key: "regular_hours")]
        private getter _regular_hours_schedules : Array(RegularHoursSchedule)?

        def regular_hours_schedules : Array(RegularHoursSchedule)
          @_regular_hours_schedules || Array(RegularHoursSchedule).new
        end

        def clear_regular_hours_schedules!
          @_regular_hours_schedules = nil
        end

        def replace_regular_hours_schedules!(schedules : Array(RegularHoursSchedule)) : Nil
          @_regular_hours_schedules = schedules
        end
      end
    end
  end
end
