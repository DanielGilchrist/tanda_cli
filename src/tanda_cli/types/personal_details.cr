module TandaCLI
  module Types
    class PersonalDetails
      include JSON::Serializable

      getter email : String
      getter gender : String?
      getter tax_file_number : String?
      getter residential_address : Address?

      @[JSON::Field(key: "emergency_contacts")]
      private getter _emergency_contacts : Array(EmergencyContact)

      def emergency_contacts : Array(EmergencyContact)
        _emergency_contacts.uniq(&.key)
      end
    end
  end
end
