module Tanda::CLI
  module CLI::ClientBuilder
    @client : API::Client? = nil

    private def client : API::Client
      @client ||= build_client_with_current_user
    end

    private def build_client_with_current_user : API::Client
      create_client_from_config.tap do |client|
        CLI::CurrentUser.new(client).set!
      end
    end

    private def create_client_from_config : API::Client
      config = Current.config
      token = config.access_token.token

      # if a token can't be parsed from the config, get username and password from user and request a token
      if token.nil?
        API::Auth.fetch_new_token!
        return create_client_from_config
      end

      url = config.api_url
      API::Client.new(url, token)
    end
  end
end
