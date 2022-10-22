require "colorize"

require "../api/client"
require "../configuration"

module Tanda::CLI
  class CLI::CurrentUser
    @api_organisations : Array(Configuration::Organisation)?
    @me : Types::Me::Core?
    @time_zone : String?

    def initialize(client : API::Client, config : Configuration)
      @client = client
      @config = config
    end

    def set!
      user = user_from_config
      user ||= user_from_api

      Current.set_user!(user)

      save_config!
    end

    private getter client : API::Client
    private getter config : Configuration

    private def user_from_config : Current::User?
      organisation = config.organisations.find(&.current?)
      return if organisation.nil?

      Current::User.new(id: organisation.user_id, time_zone: time_zone)
    end

    private def user_from_api : Current::User
      organisations = api_organisations
      organisation : Configuration::Organisation? = nil

      while organisation.nil?
        organisation = request_organisation_from_user(api_organisations)
      end

      organisation.current = true
      Current::User.new(id: organisation.user_id, time_zone: time_zone)
    end

    def me : Types::Me::Core
      @me ||= client.me
    end

    def time_zone : String
      @time_zone ||= config.time_zone || me.time_zone
    end

    def api_organisations : Array(Configuration::Organisation)
      @api_organisations ||= client.me.organisations.map do |org|
        Configuration::Organisation.from_json(org.to_json)
      end
    end

    def request_organisation_from_user(organistations : Array(Configuration::Organisation)) : Configuration::Organisation?
      organisations = api_organisations

      puts "Which organisation would you like to use?"
      api_organisations.each_with_index(1) do |org, index|
        puts "#{index}: #{org.name}"
      end
      puts "\nEnter a number: "
      user_input = gets
      user_input = user_input.chomp if user_input
      number = user_input ? user_input.to_i32? : nil

      if number
        organisations[number - 1]?
      else
        if user_input
          puts "\nInvalid selection \"#{user_input}\"\n"
        else
          puts "\nYou must select a number\n"
        end
      end
    end

    def save_config!
      config.time_zone ||= time_zone
      config.organisations = api_organisations
      config.save!
    end
  end
end
