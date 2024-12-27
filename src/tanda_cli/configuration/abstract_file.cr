module TandaCLI
  class Configuration
    abstract class AbstractFile
      abstract def read : String?
      abstract def write(content : String)
      abstract def close
    end
  end
end
