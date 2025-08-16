require "../../spec_helper"

describe TandaCLI::Commands::RegularHours::Clear do
  it "Clears regular hours on confirm" do
    stdin = build_stdin("y")
    context = run(["regular_hours", "clear"], stdin: stdin)

    context.stdout.to_s.should contain("Warning: Are you sure you want to clear regular hours for Test Organisation?")
    context.stdout.to_s.should contain("Success: Regular hours cleared for Test Organisation.")

    context.config.current_organisation!.regular_hours_schedules.should be_empty
  end

  it "Doesn't clear regular hours if not confirmed" do
    stdin = build_stdin("n")
    context = run(["regular_hours", "clear"], stdin: stdin)

    context.stdout.to_s.should contain("Warning: Are you sure you want to clear regular hours for Test Organisation?")
    context.config.current_organisation!.regular_hours_schedules.should_not be_empty
  end
end
