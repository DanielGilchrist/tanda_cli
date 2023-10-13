require "json"
require "./personal_details/**"

module TandaCLI
  module Types
    class PersonalDetails
      include JSON::Serializable

      getter email : String
      getter gender : String?
      getter tax_file_number : String?
      getter emergency_contacts : Array(EmergencyContact)
      getter residential_address : Address?
    end
  end
end
