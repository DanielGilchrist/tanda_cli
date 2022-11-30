require "../api/client"
require "../configuration"

module Tanda::CLI
  class CLI::CurrentUser
    @api_organisations : Array(Configuration::Organisation)?
    @me : Types::Me?

    def initialize(client : API::Client, config : Configuration)
      @client = client
      @config = config
    end

    def set!
      user = user_from_config || user_from_api

      {% if flag?(:debug) %}
        Utils::Display.warning("Current user is #{user.id} | #{user.organisation_name}")
        Utils::Display.warning("Time Zone is #{user.time_zone}")
      {% end %}

      Current.set_user!(user)
    end

    private getter client : API::Client
    private getter config : Configuration

    private def user_from_config : Current::User?
      organisation = config.organisations.find(&.current?)
      return if organisation.nil?

      Current::User.new(organisation.user_id, organisation.name, time_zone)
    end

    private def user_from_api : Current::User
      organisations = api_organisations
      organisation = organisations.size == 1 ? organisations[0] : nil

      while organisation.nil?
        organisation = request_organisation_from_user(organisations)
      end

      organisation.current = true
      save_config!

      puts "\n"
      Utils::Display.success("Organisations saved to config")

      Current::User.new(organisation.user_id, organisation.name, time_zone)
    end

    private def request_organisation_from_user(organistations : Array(Configuration::Organisation)) : Configuration::Organisation?
      organisations = api_organisations

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
      end
    end

    def handle_invalid_selection(length : Int32? = nil, user_input : String? = nil)
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

    private def save_config!
      config.time_zone ||= time_zone
      config.organisations = api_organisations
      config.save!
    end

    private def me : Types::Me
      @me ||= client.me.or(&.display!)
    end

    private def time_zone : String
      config.time_zone || me.time_zone
    end

    private def api_organisations : Array(Configuration::Organisation)
      @api_organisations ||= me.organisations.map do |org|
        Configuration::Organisation.from_json(org.to_json)
      end
    end
  end
end
