require "./base"
require "../types/me/**"

module Tanda::CLI
  module Representers
    class Me < Base(Types::Me)
      private def build_display
        builder << "Name: #{object.name}\n"
        builder << "Email: #{object.email}\n"
        builder << "Country: #{object.country}\n"
        builder << "Time Zone: #{object.time_zone}\n"
        builder << "Permissions: #{object.permissions.join(", ")}\n"

        display_organisations
      end

      private def display_organisations
        builder << "Organisations:\n"
        object.organisations.each do |organisation|
          Organisation.new(organisation).display
        end
      end
    end
  end
end
