require "./file"
require "./legacy/document"
require "./paths"

module TandaCLI
  module Storage
    module Migration
      private alias EnvironmentName = State::Serialisable::Environment::Name

      def self.run(environments : Hash(EnvironmentName, AbstractFile), state : AbstractFile) : Nil
        return if state.read.presence || environments.each_value.any?(&.read.presence)

        legacy = File.new(Paths.legacy_config_file)
        contents = legacy.read.presence
        return if contents.nil?

        document = Legacy::Document.parse?(contents)
        return if document.nil?

        state.write(document.state)

        environments.each do |name, file|
          configuration = document.configuration(name)
          file.write(configuration) if name.production? || !configuration.regular_hours.empty?
        end

        legacy.delete!
        legacy.delete_directory_if_empty!
      end
    end
  end
end
