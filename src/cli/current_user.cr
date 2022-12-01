require "../api/client"
require "../configuration"

module Tanda::CLI
  class CLI::CurrentUser
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
      organisations = Array(Configuration::Organisation).from_json(me.organisations.to_json)
      organisation = organisations.size == 1 ? organisations[0] : nil

      organisation = CLI::Request.organisation_from_user(organisations) if organisation.nil?

      organisation.current = true
      save_config!(organisations)

      puts "\n"
      Utils::Display.success("Organisations saved to config")

      Current::User.new(organisation.user_id, organisation.name, time_zone)
    end

    private def save_config!(organisations : Array(Configuration::Organisation))
      config.time_zone ||= time_zone
      config.organisations = organisations
      config.save!
    end

    private def me : Types::Me
      @me ||= client.me.or(&.display!)
    end

    private def time_zone : String
      config.time_zone || me.time_zone
    end
  end
end
