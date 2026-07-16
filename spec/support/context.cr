class TandaCLI::Context
  def stdout : IO
    @display.@stdout
  end

  def stderr : IO
    @display.@stderr
  end
end
