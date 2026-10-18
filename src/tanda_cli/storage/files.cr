require "./abstract_file"
require "./file"
require "./inheriting_file"
require "./migration"
require "./paths"

module TandaCLI
  module Storage
    struct Files
      def self.default : Files
        configurations = Environment.values.to_h do |environment|
          {environment, File.new(Paths.config_file(environment)).as(AbstractFile)}
        end
        state = File.new(Paths.state_file)

        Migration.run(configurations, state)

        new(configurations, state)
      end

      def initialize(@configurations : Hash(Environment, AbstractFile), @state : AbstractFile) : Nil; end

      getter state : AbstractFile

      def own_configuration(environment : Environment) : AbstractFile
        @configurations[environment]
      end

      def configuration(environment : Environment) : AbstractFile
        file = own_configuration(environment)
        return file if environment.production?

        InheritingFile.new(file, own_configuration(:production))
      end
    end
  end
end
