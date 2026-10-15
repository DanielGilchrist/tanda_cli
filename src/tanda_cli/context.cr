module TandaCLI
  class Context
    def initialize(@config_file : Configuration::AbstractFile, @display : Display, @input : Input) : Nil; end

    getter display : Display
    getter input : Input

    getter config : Configuration { Configuration.init(@config_file, @display) }

    private getter _nilable_current : Current? do
      organisation = config.current_organisation?
      Current.new(Current::User.new(organisation.user_id, organisation.name)) if organisation
    end

    private getter _nilable_client : API::Client? do
      access_token = config.access_token
      API::Client.new(config.api_url, access_token.token, _nilable_current.try(&.user)) if access_token
    end

    def client : API::Client
      _nilable_client || not_authenticated!
    end

    def current : Current
      _nilable_current || not_authenticated!
    end

    def authenticated? : Bool
      !_nilable_client.nil? && !_nilable_current.nil?
    end

    private def not_authenticated! : NoReturn
      @display.error!("Not authenticated. Run `tanda_cli auth login` to authenticate.")
    end
  end
end
