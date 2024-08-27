module TandaCLI
  module Utils
    module Auth
      extend self

      def maybe_refetch_token?(message : String, display_type : Utils::Display::Type? = nil) : Configuration?
        Utils::Input.request_and("#{message} (y/n)", display_type) do |input|
          return if input != "y"
        end

        Current.config.tap do |config|
          config.clear_access_token!
          API::Auth.fetch_new_token!
        end
      end
    end
  end
end
