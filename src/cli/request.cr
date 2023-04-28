module Tanda::CLI
  module CLI::Request
    extend self

    def ask_which_organisation_and_save!(client : API::Client, config : Configuration) : Configuration::Organisation
      me = client.me.or(&.display!)
      organisations = Configuration::Organisation.from(me)

      if organisations.empty?
        Utils::Display.error!("You don't have access to any organisations")
      end

      organisation = organisations.first if organisations.one?
      while organisation.nil?
        organisation = ask_for_organisation(organisations)
      end

      Utils::Display.success("Selected organisation \"#{organisation.name}\"")

      organisation.tap do
        save_config!(config, organisations, organisation, me.time_zone)
      end
    end

    private def save_config!(
      config : Configuration,
      organisations : Array(Configuration::Organisation),
      organisation : Configuration::Organisation,
      time_zone : String
    )
      organisation.current = true
      config.organisations = organisations
      config.time_zone = time_zone
      config.save!

      Utils::Display.success("Organisations saved to config")
    end

    private def ask_for_organisation(organisations : Array(Configuration::Organisation)) : Configuration::Organisation?
      puts "Which organisation would you like to use?"
      organisations.each_with_index(1) do |org, index|
        puts "#{index}: #{org.name}"
      end
      puts "\nEnter a number: "
      user_input = gets.try(&.chomp)
      number = user_input.try(&.to_i32?)

      if number
        index = number - 1
        organisations[index]? || handle_invalid_selection(organisations.size, user_input)
      else
        handle_invalid_selection
      end
    end

    private def handle_invalid_selection(length : Int32? = nil, user_input : String? = nil) : Nil
      puts "\n"
      if user_input
        Utils::Display.error("Invalid selection", user_input) do |sub_errors|
          sub_errors << "Please select a number between 1 and #{length}" if length
        end
      else
        Utils::Display.error("You must enter a number")
      end
    end
  end
end
