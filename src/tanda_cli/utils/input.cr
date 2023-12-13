module TandaCLI
  module Utils
    module Input
      extend self

      def request(message : String, display_type : Utils::Display::Type? = nil) : String?
        case display_type
        in Nil
          Utils::Display.print message
        in .success?
          Utils::Display.success(message)
        in .warning?
          Utils::Display.warning(message)
        in .info?
          Utils::Display.info(message)
        in .warning?
          Utils::Display.warning(message)
        in .error?
          Utils::Display.error(message)
        in .fatal?
          Utils::Display.fatal!(message)
        end

        gets.try(&.chomp).presence
      end

      def request_or(message : String, display_type : Utils::Display::Type? = nil, & : -> U) : String | U forall U
        request(message, display_type) || yield
      end

      def request_and(message : String, display_type : Utils::Display::Type? = nil, & : String? -> U) : String | U forall U
        yield(request(message, display_type))
      end
    end
  end
end
