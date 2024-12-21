require "./api/client"
require "./configuration.cr"

module TandaCLI
  class CurrentUser
    @me : Types::Me?

    def initialize(@config : Configuration, @client : API::Client); end

    def fetch
      user_from_config || user_from_api
    end

    private def user_from_config : Current::User?
      organisation = @config.current_organisation?
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
      @config.time_zone || me.time_zone
    end
  end
end
