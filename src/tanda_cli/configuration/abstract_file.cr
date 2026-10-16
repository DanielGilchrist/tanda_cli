module TandaCLI
  class Configuration
    abstract class AbstractFile
      abstract def path : String
      abstract def read : String?
      abstract def write(content : String) : Nil
    end
  end
end
