module Tanda::CLI
  module CLI::Request
    extend self

    def organisation_from_user(organisations : Array(Configuration::Organisation)) : Configuration::Organisation
      puts "\nWhich organisation would you like to use?"
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
      end || organisation_from_user(organisations)
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
      puts "\n"
    end
  end
end
