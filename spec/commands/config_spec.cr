require "../spec_helper"

describe TandaCLI::Commands::Config do
  context "path" do
    it "Prints the path to the current mode's config file" do
      context = run(["config", "path"])
      context.stdout.to_s.should contain("spec/fixtures/default/production.json")
    end

    it "Prints the path to the current mode's config file in staging" do
      context = run(["config", "path"], config_fixture: :default_staging)
      context.stdout.to_s.should contain("spec/fixtures/default_staging/staging.json")
    end

    it "Prints the path to the state file" do
      context = run(["config", "path", "--state"])
      context.stdout.to_s.should contain("spec/fixtures/default/state.json")
    end
  end

  context "inheritance" do
    it "Falls back to production when the mode has no config of its own" do
      context = run(["config", "show"], config_fixture: :inherited_staging)
      output = context.stdout.to_s

      output.should contain(%("start_of_week": "saturday"))
      output.should contain(%("regular_hours"))
    end

    it "Points at the mode's own file even while inheriting" do
      context = run(["config", "path"], config_fixture: :inherited_staging)
      context.stdout.to_s.should contain("spec/fixtures/inherited_staging/staging.json")
    end

    it "Keeps its own config once the mode has been written to" do
      context = run(["start_of_week", "set", "sunday"], config_fixture: :inherited_staging)

      staging = TandaCLI::Configuration::Serialisable.parse?(context.files.environment(:staging).read.not_nil!).not_nil!
      staging.start_of_week.should eq(Time::DayOfWeek::Sunday)
      staging.regular_hours_schedules(1).size.should eq(5)

      production = TandaCLI::Configuration::Serialisable.parse?(context.files.environment(:production).read.not_nil!).not_nil!
      production.start_of_week.should eq(Time::DayOfWeek::Saturday)
    end
  end

  context "show" do
    it "Prints the config for the current mode" do
      context = run(["config", "show"])
      output = context.stdout.to_s

      output.should contain(%("start_of_week": "saturday"))
      output.should contain(%("regular_hours"))
      output.should_not contain("testtoken")
    end

    it "Prints the state with the access token redacted" do
      context = run(["config", "show", "--state"])
      output = context.stdout.to_s

      output.should contain(%("region": "eu"))
      output.should contain(%("email": "test@testmailfakenotrealthisisntarealdomainaaaa.com"))
      output.should contain(%("token": "[redacted]"))
      output.should_not contain("testtoken")
    end

    it "Redacts the access token for the staging environment" do
      context = run(["config", "show", "--state"], config_fixture: :default_staging)
      output = context.stdout.to_s

      output.should contain(%("token": "[redacted]"))
      output.should_not contain("testtoken")
    end

    it "Errors when the config isn't valid JSON" do
      context = run(["config", "show"], config_fixture: :invalid_json)
      context.stderr.to_s.should contain("Invalid JSON!")
      context.exit_status.should eq(1)
    end
  end
end
