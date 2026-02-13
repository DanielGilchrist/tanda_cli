require "../base"
require "../../types/personal_details/emergency_contact"

module TandaCLI
  module Representers
    struct PersonalDetails
      struct EmergencyContact < Base(Types::PersonalDetails::EmergencyContact)
        private def build_display(builder : Builder)
          builder << "🏷 #{@object.name}\n"
          builder << "👥 #{@object.relationship}\n"
          builder << "📞 #{@object.phone}\n"
        end
      end
    end
  end
end
