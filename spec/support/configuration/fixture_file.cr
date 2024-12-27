class Configuration::FixtureFile < TandaCLI::Configuration::AbstractFile
  FIXTURE_PATH = "spec/fixtures/configuration"

  def self.load_fixture(fixture_name : String, display : TandaCLI::Display) : TandaCLI::Configuration
    file_io = IO::Memory.new
    fixture_bytes = File.read("#{FIXTURE_PATH}/#{fixture_name}.json").to_slice
    file_io.write(fixture_bytes)

    TandaCLI::Configuration.init(new(file_io), display)
  end

  def initialize(@io = IO::Memory.new); end

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
