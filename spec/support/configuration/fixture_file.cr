class Configuration::FixtureFile < TandaCLI::Configuration::AbstractFile
  FIXTURE_PATH = "spec/fixtures/configuration"

  enum Fixture
    Default
    DefaultStaging
    NoRegularHours

    def read : Bytes
      file_name = to_s.underscore
      path = "#{FIXTURE_PATH}/#{file_name}.json"

      File.read(path).to_slice
    end
  end

  def self.load(fixture : Fixture) : Configuration::FixtureFile
    file_io = IO::Memory.new
    file_io.write(fixture.read)

    new(file_io)
  end

  # Should be loaded with `load` with a fixture representing a configuration file
  private def initialize(@io = IO::Memory.new); end

  def read : String?
    @io.rewind.gets_to_end
  end

  def write(content : String) : Nil
    @io.clear unless @io.empty?
    @io.write(content.to_slice)
  end

  def close
    @io.close
  end
end
