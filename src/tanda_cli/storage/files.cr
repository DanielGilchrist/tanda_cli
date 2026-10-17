require "./abstract_file"
require "./file"
require "./inheriting_file"
require "./migration"
require "./paths"

module TandaCLI
  module Storage
    struct Files
      private alias EnvironmentName = State::Serialisable::Environment::Name

      def self.default : Files
        environments = EnvironmentName.values.to_h do |name|
          {name, File.new(Paths.environment_file(name)).as(AbstractFile)}
        end
        state = File.new(Paths.state_file)

        Migration.run(environments, state)

        new(environments, state)
      end

      def initialize(@environments : Hash(EnvironmentName, AbstractFile), @state : AbstractFile) : Nil; end

      getter state : AbstractFile

      def environment(name : EnvironmentName) : AbstractFile
        @environments[name]
      end

      def configuration(name : EnvironmentName) : AbstractFile
        file = environment(name)
        return file if name.production?

        InheritingFile.new(file, environment(:production))
      end
    end
  end
end
