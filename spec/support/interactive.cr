class TandaCLI::Input
  @@forced_interactive = false

  def self.forced_interactive(& : -> T) : T forall T
    @@forced_interactive = true
    yield
  ensure
    @@forced_interactive = false
  end

  def interactive? : Bool
    return true if @@forced_interactive

    stdin = @stdin
    stdin.is_a?(IO::FileDescriptor) && stdin.tty?
  end
end

def interactively(& : -> T) : T forall T
  TandaCLI::Input.forced_interactive { yield }
end
