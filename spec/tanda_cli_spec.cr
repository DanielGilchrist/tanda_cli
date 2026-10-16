require "./spec_helper"

describe TandaCLI do
  context "Main" do
    it "Running main with no arguments and working config shows help" do
      context = run(Array(String).new)
      context.stdout.to_s.should contain("A CLI application for people using Tanda/Workforce.com")
      context.stdout.to_s.should contain("Usage: tanda_cli [options] <command>")
    end

    it "Exits successfully when a command succeeds" do
      context = run(Array(String).new)
      context.exit_status.should eq(0)
    end

    it "Exits unsuccessfully when the command isn't known" do
      context = run(["definitely_not_a_command"])
      context.stderr.to_s.should contain("isn't a known command")
      context.exit_status.should eq(1)
    end

    it "Exits unsuccessfully when a command errors" do
      context = run(["me"], config_fixture: :unauthenticated)
      context.stderr.to_s.should contain("Not authenticated")
      context.exit_status.should eq(1)
    end

    it "Shows staging warning when in staging mode" do
      context = run(["current_user", "display"], config_fixture: :default_staging)
      context.stdout.to_s.should contain("Warning: Command running in staging mode")
    end
  end
end
