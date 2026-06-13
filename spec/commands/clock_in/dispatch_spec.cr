require "./spec_helper"

describe TandaCLI::Commands::ClockIn do
  it "shows help for --help" do
    context = run(["clockin", "--help"])

    output = context.stdout.to_s
    output.should contain("Usage: clockin [options] <command>")
    output.should contain("Clock in/out")
    output.should contain("start")
    output.should contain("backfill")
    output.should contain("-h, --help")
    context.stderr.to_s.should be_empty
  end

  it "shows help when run bare" do
    context = run(["clockin"])

    context.stdout.to_s.should contain("Usage: clockin [options] <command>")
    context.stderr.to_s.should be_empty
  end

  it "shows subcommand help for `clockin start --help`" do
    context = run(["clockin", "start", "--help"])

    output = context.stdout.to_s
    output.should contain("Usage: start [options]")
    output.should contain("-a, --at <value>")
    output.should contain("-s, --skip-validations")
  end

  it "errors on unknown commands listing candidates" do
    context = run(["clockin", "strat"])

    context.stderr.to_s.should eq(
      "Error: Unknown command!\n" \
      "       \"strat\" isn't a known command (expected one of: backfill, break, display, finish, photo, start, status).\n"
    )
    context.stdout.to_s.should be_empty
  end

  it "errors on unknown options" do
    context = run(["clockin", "start", "--nope"])

    context.stderr.to_s.should eq(
      "Error: Unknown option!\n" \
      "       \"--nope\" isn't a recognised option.\n"
    )
  end

  it "runs photo subcommands" do
    context = run(["clockin", "photo", "view"])

    context.stdout.to_s.should eq("No clock in photo set\n")
    context.stderr.to_s.should be_empty
  end

  it "still lists clockin in the main help" do
    context = run([] of String)

    context.stdout.to_s.should contain("clockin")
  end
end
