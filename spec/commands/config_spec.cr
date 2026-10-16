require "../spec_helper"

describe TandaCLI::Commands::Config do
  context "path" do
    it "Prints the path to the configuration file" do
      context = run(["config", "path"])
      context.stdout.to_s.should contain("spec/fixtures/configuration/default.json")
    end
  end

  context "show" do
    it "Prints the configuration with the access token redacted" do
      context = run(["config", "show"])
      output = context.stdout.to_s

      output.should contain(%("email": "test@testmailfakenotrealthisisntarealdomainaaaa.com"))
      output.should contain(%("token": "[redacted]"))
      output.should_not contain("testtoken")
    end

    it "Redacts the access token for the staging environment" do
      context = run(["config", "show"], config_fixture: :default_staging)
      output = context.stdout.to_s

      output.should contain(%("token": "[redacted]"))
      output.should_not contain("testtoken")
    end

    it "Errors when the configuration isn't valid JSON" do
      context = run(["config", "show"], config_fixture: :invalid_json)
      context.stderr.to_s.should contain("Invalid config!")
      context.exit_status.should eq(1)
    end
  end
end
