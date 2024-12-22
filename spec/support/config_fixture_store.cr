require "../../src/tanda_cli/configuration/store"

class ConfigFixtureStore < TandaCLI::Configuration::Store
  FIXTURE_PATH = "spec/fixtures/configuration"

  def self.load_fixture(fixture_name) : TandaCLI::Configuration
    io = IO::Memory.new
    fixture_bytes = File.read("#{FIXTURE_PATH}/#{fixture_name}.json").to_slice
    io.write(fixture_bytes)

    store = new(io)
    TandaCLI::Configuration.init(store)
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
