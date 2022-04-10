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
        display_with_padding("ID: #{organisation.id}")
        display_with_padding("Name: #{organisation.name}")
        display_with_padding("Country: #{organisation.country}")
        display_with_padding("User ID: #{organisation.user_id}")
        display_with_padding("Locale: #{organisation.locale}")
        puts "\n"
      end

      private def display_with_padding(text)
        puts "    #{text}"
      end
    end
  end
end
