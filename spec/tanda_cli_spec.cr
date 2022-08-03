require "./spec_helper"

describe Tanda::CLI do
  context "Main" do
    before_each do
      Tanda::CLI::Current.reset!
    end

    it "Running main with no arguments passes" do
      Tanda::CLI.main
    end
  end
end
