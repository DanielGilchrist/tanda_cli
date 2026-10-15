require "../spec_helper"

describe TandaCLI::Commands::Completions do
  it "Prints a completion script" do
    context = run(["completions", "fish"])

    context.stdout.to_s.should contain("tanda_cli fish completion")
    context.stderr.to_s.should be_empty
  end

  it "Prints a completion script without reading an invalid config" do
    context = run(["completions", "fish"], config_fixture: :invalid_json)

    context.stdout.to_s.should contain("tanda_cli fish completion")
    context.stderr.to_s.should be_empty
  end
end
