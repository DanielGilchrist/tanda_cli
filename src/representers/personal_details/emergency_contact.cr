require "../base"
require "../../types/personal_details/emergency_contact"

module Tanda::CLI
  module Representers
    class PersonalDetails
      class EmergencyContact < Base(Types::PersonalDetails::EmergencyContact)
        private def build_display(builder : String::Builder)
          builder << "🏷  #{object.name}\n"
          builder << "👥 #{object.relationship}\n"
          builder << "📞 #{object.phone}\n"
        end
      end
    end
  end
end
