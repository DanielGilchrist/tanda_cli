module TandaCLI
  class Context
    def initialize(@stdout : IO, @config : Configuration, @client : API::Client, @current : Current, @display : Display, @input : Input); end

    getter stdout : IO
    getter config : Configuration
    getter client : API::Client
    getter current : Current
    getter display : Display
    getter input : Input
  end
end
