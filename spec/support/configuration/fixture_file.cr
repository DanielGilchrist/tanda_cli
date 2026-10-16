class Configuration::FixtureFile < TandaCLI::Configuration::AbstractFile
  FIXTURE_PATH = "spec/fixtures/configuration"

  enum Fixture
    Default
    DefaultStaging
    InvalidJson
    MondayStartOfWeek
    NoRegularHours
    OvernightRegularHours
    Unauthenticated

    def path : String
      "#{FIXTURE_PATH}/#{to_s.underscore}.json"
    end

    def read : Bytes
      File.read(path).to_slice
    end
  end

  def self.load(fixture : Fixture) : Configuration::FixtureFile
    file_io = IO::Memory.new
    file_io.write(fixture.read)

    new(fixture.path, file_io)
  end

  # Should be loaded with `load` with a fixture representing a configuration file
  private def initialize(@path : String, @io : IO::Memory = IO::Memory.new) : Nil; end

  getter path : String

  def read : String?
    @io.rewind.gets_to_end
  end

  def write(content : String) : Nil
    @io.clear unless @io.empty?
    @io.write(content.to_slice)
  end
end
