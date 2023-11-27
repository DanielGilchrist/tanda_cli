require "./api/client"
require "./configuration.cr"

module TandaCLI
  class CurrentUser
    @me : Types::Me?

    def initialize(@client : API::Client); end

    def set!
      user = user_from_config || user_from_api

      {% if flag?(:debug) %}
        Utils::Display.info("Current user is #{user.id} | #{user.organisation_name}")
        Utils::Display.info("Time Zone is #{user.time_zone}")
      {% end %}

      Current.set_user!(user)
    end

    private def config : Configuration
      Current.config
    end

    private def user_from_config : Current::User?
      organisation = config.current_organisation?
      return if organisation.nil?

      Current::User.new(organisation.user_id, organisation.name, time_zone)
    end

    private def user_from_api : Current::User
      organisation = Request.ask_which_organisation_and_save!(@client, config)
      Current::User.new(organisation.user_id, organisation.name, time_zone)
    end

    private def me : Types::Me
      @me ||= @client.me.or(&.display!)
    end

    private def time_zone : String
      config.time_zone || me.time_zone
    end
  end
end
