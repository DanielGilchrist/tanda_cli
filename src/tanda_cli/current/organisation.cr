module TandaCLI
  class Current
    struct Organisation
      def initialize(@record : State::Serialisable::Organisation, @configuration : Configuration) : Nil; end

      delegate :id, :name, :user_id, to: @record

      def regular_hours_schedules : Array(Models::RegularHoursSchedule)
        @configuration.regular_hours_schedules(id)
      end

      def replace_regular_hours_schedules!(schedules : Array(Models::RegularHoursSchedule)) : Nil
        @configuration.replace_regular_hours_schedules!(id, schedules)
      end

      def clear_regular_hours_schedules! : Nil
        @configuration.clear_regular_hours_schedules!(id)
      end
    end
  end
end
