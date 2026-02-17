module TandaCLI
  class Configuration
    class Serialisable
      class Environment
        include JSON::Serializable

        def initialize(
          @region : Region = Region::APAC,
          @access_token : AccessToken = AccessToken.new,
          @organisations : Array(Organisation) = Array(Organisation).new,
        ); end

        property region : Region = Region::APAC
        property access_token : AccessToken
        property organisations : Array(Organisation)

        def current_organisation! : Organisation | NoReturn
          current_organisation? || raise("No current organisation set!")
        end

        def current_organisation? : Organisation?
          @organisations.find(&.current?)
        end
      end
    end
  end
end
