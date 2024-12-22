require "./spec_helper"

Spectator.describe TandaCLI do
  context "Main" do
    it "Running main with no arguments passes" do
      io = IO::Memory.new
      TandaCLI.main([] of String, io)

      expect(io.to_s).to contain("A CLI application for people using Tanda/Workforce.com")
    end
  end
end
