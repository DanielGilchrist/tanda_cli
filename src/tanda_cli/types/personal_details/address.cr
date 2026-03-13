module TandaCLI
  module Types
    struct PersonalDetails
      struct Address
        include JSON::Serializable

        getter street_line_one : String?
        getter street_line_two : String?
        getter city : String?
        getter state : String?
        getter postcode : String?
        getter country : String?
      end
    end
  end
end
