class Storage::FixtureFile < TandaCLI::Storage::AbstractFile
  def self.load(path : String) : Storage::FixtureFile
    io = IO::Memory.new
    io << File.read(path) if File.exists?(path)

    new(path, io)
  end

  private def initialize(@path : String, @io : IO::Memory) : Nil; end

  getter path : String

  def read : String?
    @io.rewind.gets_to_end
  end

  def write(content : String) : Nil
    @io.clear unless @io.empty?
    @io.write(content.to_slice)
  end
end
