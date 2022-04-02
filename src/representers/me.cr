require "../types/me/**"

module Tanda::CLI
  module Representers
    class Me
      def initialize(object : Types::Me::Core)
        @object = object
      end

      def display
        puts "Name: #{object.name}"
        puts "Email: #{object.email}"

        puts "Organisations:"
        object.user_ids.each do |user_id|
          organisation = object.organisations.find { |o| o.user_id == user_id }
          next if organisation.nil?

          display_organisation(organisation)
        end
      end

      private getter object

      private def display_organisation(organisation : Types::Me::Organisation)
        puts "\tID: #{organisation.id}"
        puts "\tName: #{organisation.name}"
        puts "\tCountry: #{organisation.country}"
        puts "\n"
      end
    end
  end
end
