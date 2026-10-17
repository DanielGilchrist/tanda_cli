module TandaCLI
  module Storage
    module Legacy
      struct Organisation
        include JSON::Serializable

        getter id : Int32
        getter name : String
        getter user_id : Int32

        @[JSON::Field(key: "current")]
        getter? current : Bool = false

        @[JSON::Field(key: "regular_hours")]
        getter regular_hours_schedules : Array(Models::RegularHoursSchedule)?

        def to_state : State::Serialisable::Organisation
          State::Serialisable::Organisation.new(id, name, user_id, current?)
        end
      end
    end
  end
end
