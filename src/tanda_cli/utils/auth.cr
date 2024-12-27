module TandaCLI
  module Utils
    module Auth
      extend self

      def maybe_refetch_token?(config : Configuration, display : Display, input : Input, message : String, display_type : Display::Type? = nil) : Configuration?
        input.request_and("#{message} (y/n)", display_type) do |input|
          return if input != "y"
        end

        config.tap do
          API::Auth.fetch_new_token!(config, display, input)
        end
      end
    end
  end
end
