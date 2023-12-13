module TandaCLI
  module Utils
    module Input
      extend self

      def request(message : String, display_type : Utils::Display::Type? = nil) : String?
        case display_type
        in Nil
          puts message
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

      def request_or(message : String, & : -> U) : String | U forall U
        request(message) || yield
      end
    end
  end
end
