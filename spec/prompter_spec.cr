require "./spec_helper"

private def prompter(stdin : IO, stdout : IO) : TandaCLI::Prompter
  display = TandaCLI::Display.new(stdout, IO::Memory.new)

  TandaCLI::Prompter.new(TandaCLI::Input.new(stdin, display), display)
end

describe TandaCLI::Prompter do
  it "Leaves a space between the question and what you type" do
    stdout = IO::Memory.new
    prompter(build_stdin("tomorrow"), stdout).ask("First day?")

    stdout.to_s.should eq("First day? › ")
  end

  it "Doesn't lead with a blank line" do
    stdout = IO::Memory.new
    prompter(build_stdin("a"), stdout).ask("First?")

    stdout.to_s.should_not start_with("\n")
  end

  it "Puts one blank line between consecutive questions" do
    stdout = IO::Memory.new
    asker = prompter(build_stdin("a", "b"), stdout)

    asker.ask("First?")
    asker.ask("Second?")

    stdout.to_s.should eq("First? › \nSecond? › ")
  end

  it "Puts one blank line before a block" do
    stdout = IO::Memory.new
    display = TandaCLI::Display.new(stdout, IO::Memory.new)
    asker = TandaCLI::Prompter.new(TandaCLI::Input.new(build_stdin("a"), display), display)

    asker.ask("First?")
    asker.lines { display.puts "  1  Holiday Leave" }

    stdout.to_s.should eq("First? › \n  1  Holiday Leave\n")
  end

  it "Returns an empty string for Enter and nil for a closed stdin" do
    display = TandaCLI::Display.new(IO::Memory.new, IO::Memory.new)
    asker = TandaCLI::Prompter.new(TandaCLI::Input.new(build_stdin(""), display), display)

    asker.ask("First?").should eq("")
    asker.ask("Second?").should be_nil
  end
end
