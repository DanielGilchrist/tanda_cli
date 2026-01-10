module TandaCLI
  module Representers
    class PersonalDetails
      class Address < Base(Types::PersonalDetails::Address)
        private def build_display(builder : String::Builder)
          address_string = {
            @object.street_line_one,
            @object.street_line_two,
            @object.city,
            @object.state,
            @object.postcode,
            @object.country,
          }.compact_map(&.presence).join(", ")

          builder << address_string if address_string.presence
        end
      end
    end
  end
end
