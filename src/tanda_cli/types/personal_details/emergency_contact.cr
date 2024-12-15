module TandaCLI
  module Types
    class PersonalDetails
      class EmergencyContact
        include JSON::Serializable

        getter name : String
        getter relationship : String
        getter phone : String

        # Currently the personal details endpoint doesn't contain a way to differenciate
        # between personal details between users which can result in duplicates
        def key : String
          "#{name}-#{relationship}-#{phone}"
        end
      end
    end
  end
end
