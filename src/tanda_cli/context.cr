module TandaCLI
  class Context
    def initialize(@io = IO::Memory, @config = Config, @client = API::Client, @current = Current); end

    getter io : IO::Memory
    getter config : Configuration
    getter client : API::Client
    getter current : Current
  end
end
