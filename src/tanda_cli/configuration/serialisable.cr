module TandaCLI
  class Configuration
    class Serialisable
      include JSON::Serializable

      def self.parse?(contents : String) : Serialisable?
        from_json(contents)
      rescue JSON::Error
        nil
      end

      def initialize(
        @clockin_photo_path : String? = nil,
        @start_of_week : Time::DayOfWeek = Time::DayOfWeek::Monday,
        @treat_paid_breaks_as_unpaid : Bool = false,
        @regular_hours : Models::RegularHoursByOrganisation = Models::RegularHoursByOrganisation.new,
      ) : Nil; end

      property clockin_photo_path : String?
      property start_of_week : Time::DayOfWeek = Time::DayOfWeek::Monday

      @[JSON::Field(emit_null: true)]
      property? treat_paid_breaks_as_unpaid : Bool = false

      property regular_hours : Models::RegularHoursByOrganisation = Models::RegularHoursByOrganisation.new

      def pretty_start_of_week : String
        @start_of_week.to_s
      end

      def regular_hours_schedules(organisation_id : Int32) : Array(Models::RegularHoursSchedule)
        regular_hours[organisation_id]? || Array(Models::RegularHoursSchedule).new
      end

      def replace_regular_hours_schedules!(organisation_id : Int32, schedules : Array(Models::RegularHoursSchedule)) : Nil
        regular_hours[organisation_id] = schedules
      end

      def clear_regular_hours_schedules!(organisation_id : Int32) : Nil
        regular_hours.delete(organisation_id)
      end
    end
  end
end
