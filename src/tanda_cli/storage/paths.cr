module TandaCLI
  module Storage
    module Paths
      APPLICATION = "tanda_cli"

      CONFIG_DIR_VARIABLE = "TANDA_CLI_CONFIG_DIR"
      DATA_DIR_VARIABLE   = "TANDA_CLI_DATA_DIR"

      XDG_CONFIG_HOME_VARIABLE = "XDG_CONFIG_HOME"
      XDG_DATA_HOME_VARIABLE   = "XDG_DATA_HOME"

      def self.config_file(environment : Environment) : Path
        config_dir / environment.file_name
      end

      def self.state_file : Path
        data_dir / "state.json"
      end

      def self.legacy_config_file : Path
        Path.home / ".#{APPLICATION}" / "config.json"
      end

      def self.config_dir : Path
        from_environment(CONFIG_DIR_VARIABLE) ||
          application_dir(XDG_CONFIG_HOME_VARIABLE, Path.home / ".config")
      end

      def self.data_dir : Path
        from_environment(DATA_DIR_VARIABLE) ||
          application_dir(XDG_DATA_HOME_VARIABLE, Path.home / ".local" / "share")
      end

      private def self.application_dir(variable : String, fallback : Path) : Path
        (from_environment(variable) || fallback) / APPLICATION
      end

      private def self.from_environment(variable : String) : Path?
        directory = ENV[variable]?.presence
        Path.new(directory).expand(home: true) if directory
      end
    end
  end
end
