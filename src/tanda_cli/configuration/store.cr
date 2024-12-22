module TandaCLI
  class Configuration
    abstract class Store
      abstract def read : String?
      abstract def write(content : String)
      abstract def close
    end
  end
end
