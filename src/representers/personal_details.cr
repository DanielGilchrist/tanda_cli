require "colorize"

require "./base"
require "../types/personal_details/**"

module Tanda::CLI
  module Representers
    class PersonalDetails < Base(Types::PersonalDetails)
      private def build_display(builder : String::Builder)
        builder << "📖 Personal Details\n".colorize.white

        builder << "📧 #{object.email}\n"

        gender = object.gender
        builder << "⚧ #{gender}\n" if gender

        tax_file_number = object.tax_file_number
        builder << "🪪 #{tax_file_number}\n" if tax_file_number

        build_emergency_contacts(builder)
        build_address(builder)
      end

      private def build_emergency_contacts(builder : String::Builder)
        return if object.emergency_contacts.empty?

        builder << "\n🚑 Emergency Contacts\n".colorize.white.bold

        object.emergency_contacts.each do |contact|
          builder << EmergencyContact.new(contact).build
        end
      end

      private def build_address(builder : String::Builder)
        address = object.residential_address
        return if address.nil?

        builder << "🏠 Address\n".colorize.white.bold
        builder << Address.new(address).build
      end
    end
  end
end
