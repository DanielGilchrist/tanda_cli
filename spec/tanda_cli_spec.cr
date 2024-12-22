require "./spec_helper"

describe TandaCLI do
  context "Main" do
    it "Running main with no arguments passes" do
      io = IO::Memory.new
      TandaCLI.main([] of String, io)

      io.to_s.should contain("A CLI application for people using Tanda/Workforce.com")
    end
  end
end
