module TandaCLI
  module Utils
    module Auth
      extend self

      def maybe_refetch_token?(config : Configuration, message : String, display_type : Utils::Display::Type? = nil) : Configuration?
        Utils::Input.request_and("#{message} (y/n)", display_type) do |input|
          return if input != "y"
        end

        config.tap do
          API::Auth.fetch_new_token!(config)
        end
      end
    end
  end
end
