require "./spec_helper"

Spectator.describe Tanda::CLI do
  context "Main" do
    it "Running main with no arguments passes" do
      Tanda::CLI.main([] of String)
    end
  end
end
