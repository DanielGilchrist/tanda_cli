module TandaCLI
  class Context
    def initialize(@config : Configuration, @client : API::Client, @current : Current, @display : Display, @input : Input); end

    getter config : Configuration
    getter client : API::Client
    getter current : Current
    getter display : Display
    getter input : Input

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
