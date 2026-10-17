require "json"

module TandaCLI
  module Storage
    abstract class AbstractFile
      abstract def path : String
      abstract def read : String?
      abstract def write(content : String) : Nil

      def write(document : JSON::Serializable) : Nil
        contents = "#{document.to_pretty_json}\n"
        return if contents == read

        write(contents)
      end
    end
  end
end
