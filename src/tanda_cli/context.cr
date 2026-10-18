module TandaCLI
  class Context
    def initialize(@files : Storage::Files, @display : Display, @input : Input) : Nil; end

    getter files : Storage::Files
    getter display : Display
    getter input : Input
    property exit_status : Int32 = ExitProgram::SUCCESS

    getter state : State { State.init(@files.state, @display) }
    getter config : Configuration { Configuration.init(@files.configuration(state.current_environment), @input, @display) }

    private getter _nilable_current : Current? do
      organisation = state.current_organisation?
      Current.new(Current::User.new(organisation.user_id, organisation.name)) if organisation
    end

    private getter _nilable_client : API::Client? do
      access_token = state.access_token
      API::Client.new(state.api_url, access_token.token, _nilable_current.try(&.user)) if access_token
    end

    def client : API::Client
      _nilable_client || not_authenticated!
    end

    def current : Current
      _nilable_current || not_authenticated!
    end

    def current_organisation? : Current::Organisation?
      organisation = state.current_organisation?
      Current::Organisation.new(organisation, config) if organisation
    end

    def current_organisation! : Current::Organisation
      current_organisation? || no_current_user!
    end

    def authenticated? : Bool
      !_nilable_client.nil? && !_nilable_current.nil?
    end

    private def not_authenticated! : NoReturn
      @display.error!(Error::NotAuthenticated.new)
    end

    private def no_current_user! : NoReturn
      not_authenticated! if state.access_token.nil?

      @display.error!(Error::NoCurrentUser.new)
    end
  end
end
