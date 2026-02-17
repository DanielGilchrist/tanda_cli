module TandaCLI
  class Context
    def initialize(@config : Configuration, @client : API::Client?, @current : Current?, @display : Display, @input : Input); end

    getter config : Configuration
    getter display : Display
    getter input : Input

    def client : API::Client
      @client || not_authenticated!
    end

    def current : Current
      @current || not_authenticated!
    end

    def authenticated? : Bool
      !@client.nil? && !@current.nil?
    end

    private def not_authenticated! : NoReturn
      @display.error!("Not authenticated. Run `tanda_cli auth login` to authenticate.")
    end

    {% if flag?(:test) %}
      def stdout : IO
        @display.@stdout
      end

      def stderr : IO
        @display.@stderr
      end
    {% end %}
  end
end
