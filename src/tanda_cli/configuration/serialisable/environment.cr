module TandaCLI
  class Configuration
    class Serialisable
      class Environment
        include JSON::Serializable

        DEFAULT_SITE_PREFIX = "eu"

        def initialize(
          @site_prefix : String = DEFAULT_SITE_PREFIX,
          @access_token : AccessToken = AccessToken.new,
          @organisations : Array(Organisation) = Array(Organisation).new,
        ); end

        property site_prefix : String
        property access_token : AccessToken
        property organisations : Array(Organisation)

        def current_organisation! : Organisation | NoReturn
          current_organisation? || Utils::Display.error!("No current organisation set!")
        end

        def current_organisation? : Organisation?
          @organisations.find(&.current?)
        end
      end
    end
  end
end
