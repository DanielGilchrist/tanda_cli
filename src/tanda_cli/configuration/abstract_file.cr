module TandaCLI
  class Configuration
    abstract class AbstractFile
      abstract def read : String?
      abstract def write(content : String) : Nil
      abstract def close : Nil
    end
  end
end
