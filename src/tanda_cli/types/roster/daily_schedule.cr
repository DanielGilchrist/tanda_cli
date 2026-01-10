module TandaCLI
  module Types
    class Roster
      class DailySchedule
        include JSON::Serializable

        module DateConverter
          def self.from_json(value : JSON::PullParser) : Time
            date_string = value.read_string
            Utils::Time.iso_date(date_string)
          end
        end

        @[JSON::Field(key: "date", converter: TandaCLI::Types::Roster::DailySchedule::DateConverter)]
        getter date : Time

        getter schedules : Array(Types::Schedule)
      end
    end
  end
end
