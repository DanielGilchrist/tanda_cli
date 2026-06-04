require "../base"
require "../../api/types/personal_details/address"

module TandaCLI
  module Representers
    struct PersonalDetails
      struct Address < Base(API::Types::PersonalDetails::Address)
        private def build_display(builder : Builder)
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
