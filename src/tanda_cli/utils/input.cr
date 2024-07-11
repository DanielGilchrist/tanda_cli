module TandaCLI
  module Utils
    module Input
      extend self

      def request(message : String, display_type : Utils::Display::Type? = nil, sensitive : Bool = false) : String?
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

        retrieve_input(sensitive) do
          gets.try(&.chomp).presence
        end
      end

      def request_or(message : String, display_type : Utils::Display::Type? = nil, sensitive : Bool = false, & : -> U) : String | U forall U
        request(message, display_type, sensitive) || yield
      end

      def request_and(message : String, display_type : Utils::Display::Type? = nil, sensitive : Bool = false, & : String? -> U) : String | U forall U
        yield(request(message, display_type, sensitive))
      end

      private def retrieve_input(sensitive : Bool, & : -> String?) : String?
        return yield unless sensitive

        STDIN.noecho do
          yield
        end
      end
    end
  end
end
