module TandaCLI
  module Utils
    module Input
      extend self

      def request_input(message : String, display_type : Utils::Display::Type? = nil) : String?
        puts message
        messsage = gets.try(&.chomp).presence

        case display_type
        in Nil
          message
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
      end

      def request_input_or(message : String, &) : String
        request_input(message) || yield
      end
    end
  end
end
