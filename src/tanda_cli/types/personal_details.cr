require "json"
require "./personal_details/**"

module TandaCLI
  module Types
    class PersonalDetails
      include JSON::Serializable

      getter email : String
      getter gender : String?
      getter tax_file_number : String?

      @[JSON::Field(key: "emergency_contacts")]
      getter _emergency_contacts : Array(EmergencyContact)

      getter residential_address : Address?

      def emergency_contacts : Array(EmergencyContact)
        _emergency_contacts.uniq(&.key)
      end
    end
  end
end
