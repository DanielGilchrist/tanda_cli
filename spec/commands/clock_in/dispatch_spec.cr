require "./spec_helper"

describe TandaCLI::Commands::ClockIn do
  it "shows help for --help" do
    context = run(["clockin", "--help"])

    output = context.stdout.to_s
    output.should contain("Usage: tanda_cli clockin <command>")
    output.should contain("Clock in/out")
    output.should contain("start")
    output.should contain("backfill")
    output.should contain("-h, --help")
    context.stderr.to_s.should be_empty
  end

  it "shows help when run bare" do
    context = run(["clockin"])

    context.stdout.to_s.should contain("Usage: tanda_cli clockin <command>")
    context.stderr.to_s.should be_empty
  end

  it "shows subcommand help for `clockin start --help`" do
    context = run(["clockin", "start", "--help"])

    output = context.stdout.to_s
    output.should contain("Usage: tanda_cli clockin start [options]")
    output.should contain("-a, --at <value>")
    output.should contain("-s, --skip-validations")
  end

  it "errors on unknown commands and lists them as context" do
    context = run(["clockin", "strat"])

    stderr = context.stderr.to_s
    stderr.should contain("Error: \"strat\" isn't a known command.")
    stderr.should contain("Usage: tanda_cli clockin <command>")
    stderr.should contain("Commands:")
    stderr.should contain("backfill")
    stderr.should contain("start")
    context.stdout.to_s.should be_empty
  end

  it "errors on unknown options and lists them as context" do
    context = run(["clockin", "start", "--nope"])

    stderr = context.stderr.to_s
    stderr.should contain("Error: \"--nope\" isn't a recognised option.")
    stderr.should contain("Usage: tanda_cli clockin start [options]")
    stderr.should contain("Options:")
    stderr.should contain("-a, --at <value>")
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
