require "../base"
require "../../types/me/**"

module Tanda::CLI
  module Representers
    module Me
      class Core < Base(Types::Me::Core)
        def display
          puts "Name: #{object.name}"
          puts "Email: #{object.email}"
          puts "Country: #{object.country}"
          puts "Time Zone: #{object.time_zone}"
          puts "Permissions: #{object.permissions.join(", ")}"

          display_organisations
        end

        private def display_organisations
          puts "Organisations:"
          object.organisations.each do |organisation|
            Organisation.new(organisation).display
          end
        end
      end
    end
  end
end
