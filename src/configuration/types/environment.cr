module Tanda::CLI
  class Configuration
    class Environment
      include JSON::Serializable

      DEFAULT_SITE_PREFIX = "eu"

      def initialize(
        @site_prefix : String = DEFAULT_SITE_PREFIX,
        @access_token : AccessToken = AccessToken.new,
        @organisations : Array(Organisation) = Array(Organisation).new,
        @time_zone : String? = nil
      ); end

      property site_prefix : String
      property access_token : AccessToken
      property organisations : Array(Organisation)
      property time_zone : String?

      def clear_access_token!
        @access_token = AccessToken.new
      end

      def current_organisation! : Organisation
        @organisations.find(&.current?) || Utils::Display.error!("No current organisation set!")
      end
    end
  end
end
