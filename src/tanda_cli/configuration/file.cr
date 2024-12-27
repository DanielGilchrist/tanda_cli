require "./abstract_file"

module TandaCLI
  class Configuration
    class File < Configuration::AbstractFile
      CONFIG_DIR  = "#{Path.home}/.tanda_cli"
      CONFIG_PATH = "#{CONFIG_DIR}/config.json"

      def read : String?
        return unless ::File.exists?(CONFIG_PATH)
        ::File.read(CONFIG_PATH)
      end

      def write(content : String)
        FileUtils.mkdir_p(CONFIG_DIR) unless ::File.directory?(CONFIG_DIR)
        ::File.write(CONFIG_PATH, content)
      end

      def close
        # no-op
      end
    end
  end
end
