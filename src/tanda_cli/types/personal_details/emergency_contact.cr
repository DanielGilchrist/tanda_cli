module TandaCLI
  module Types
    class PersonalDetails
      class EmergencyContact
        include JSON::Serializable

        getter name : String
        getter relationship : String
        getter phone : String
      end
    end
  end
end
