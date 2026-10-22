require "json"
require "./converters/time"

module TandaCLI
  module API
    module Types
      struct LeaveCreate
        include JSON::Serializable

        PENDING = "pending"

        def self.from(user_id : Int32, draft : Models::LeaveDraft) : LeaveCreate
          new(
            user_id: user_id,
            start: Utils::Time.iso_date(draft.start),
            finish: Utils::Time.iso_date(draft.finish),
            leave_type: draft.leave_type.name,
            status: PENDING,
            hours: draft.hours.total_hours,
            all_day: true,
            reason: draft.reason,
          )
        end

        private def initialize(
          @user_id : Int32,
          @start : String,
          @finish : String,
          @leave_type : String,
          @status : String,
          @hours : Float64,
          @all_day : Bool,
          @reason : String?,
        ) : Nil; end

        getter user_id : Int32
        getter start : String
        getter finish : String
        getter leave_type : String
        getter status : String
        getter hours : Float64
        getter? all_day : Bool

        @[JSON::Field(emit_null: false)]
        getter reason : String?
      end
    end
  end
end
