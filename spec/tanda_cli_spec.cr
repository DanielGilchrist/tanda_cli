require "./spec_helper"

describe TandaCLI do
  context "Main" do
    it "Running main with no arguments and working config shows help" do
      context = run(Array(String).new)
      context.stdout.to_s.should contain("A CLI application for people using Tanda/Workforce.com")
      context.stdout.to_s.should contain("tanda_cli <command> [options]")
    end

    it "Shows staging warning when in staging mode" do
      context = run(["current_user", "display"], config_fixture: :default_staging)
      context.stdout.to_s.should contain("Warning: Command running in staging mode")
    end
  end
end
