require "./spec_helper"

describe TandaCLI::Configuration do
  it "Errors instead of hanging when the config is invalid and nothing confirms" do
    context = run(["start_of_week", "display"], config_fixture: :invalid_json)

    context.stderr.to_s.should contain("Invalid config!")
    context.stderr.to_s.should contain("spec/fixtures/invalid_json/production.json")
    context.exit_status.should eq(1)
  end

  it "Continues with a default config when the user confirms" do
    context = run(["start_of_week", "display"], stdin: build_stdin(""), config_fixture: :invalid_json)

    context.stdout.to_s.should contain("Monday")
    context.exit_status.should eq(0)
  end
end
