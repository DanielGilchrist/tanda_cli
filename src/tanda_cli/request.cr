module TandaCLI
  module Request
    extend self

    def ask_which_organisation_and_save!(client : API::Client, config : Configuration, display : Display, input : Input) : Configuration::Serialisable::Organisation
      me = client.me.unwrap!
      organisations = Configuration::Serialisable::Organisation.from(me)

      if organisations.empty?
        display.error!("You don't have access to any organisations")
      end

      organisation = organisations.first if organisations.one?
      while organisation.nil?
        organisation = ask_for_organisation(organisations, display, input)
      end

      display.success("Selected organisation \"#{organisation.name}\"")

      organisation.tap do
        organisation.current = true
        config.organisations = organisations
        config.save!

        display.success("Organisations saved to config")
      end
    end

    private def ask_for_organisation(
      organisations : Array(Configuration::Serialisable::Organisation),
      display : Display,
      input : Input,
    ) : Configuration::Serialisable::Organisation?
      display.puts "Which organisation would you like to use?"
      organisations.each_with_index(1) do |org, index|
        display.puts "#{index}: #{org.name}"
      end

      input.request_and(message: "\nEnter a number: ") do |user_input|
        number = user_input.try(&.to_i32?)

        if number
          index = number - 1
          organisations[index]? || handle_invalid_selection(display, organisations.size, user_input)
        else
          handle_invalid_selection(display)
        end
      end
    end

    private def handle_invalid_selection(display : Display, length : Int32? = nil, user_input : String? = nil) : Nil
      display.puts "\n"
      if user_input
        display.error("Invalid selection", user_input) do |sub_errors|
          sub_errors << "Please select a number between 1 and #{length}" if length
        end
      else
        display.error("You must enter a number")
      end
    end
  end
end
