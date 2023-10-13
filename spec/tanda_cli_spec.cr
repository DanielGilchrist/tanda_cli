require "./spec_helper"

Spectator.describe TandaCLI do
  context "Main" do
    it "Running main with no arguments passes" do
      TandaCLI.main([] of String)
    end
  end
end
