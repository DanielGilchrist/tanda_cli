require "./file"
require "./legacy/document"
require "./paths"

module TandaCLI
  module Storage
    module Migration
      def self.run(configurations : Hash(Environment, AbstractFile), state : AbstractFile) : Nil
        return if state.read.presence || configurations.each_value.any?(&.read.presence)

        legacy = File.new(Paths.legacy_config_file)
        contents = legacy.read.presence
        return if contents.nil?

        document = Legacy::Document.parse?(contents)
        return if document.nil?

        state.write(document.state)

        configurations.each do |environment, file|
          configuration = document.configuration(environment)
          file.write(configuration) if environment.production? || !configuration.regular_hours.empty?
        end

        legacy.delete!
        legacy.delete_directory_if_empty!
      end
    end
  end
end
