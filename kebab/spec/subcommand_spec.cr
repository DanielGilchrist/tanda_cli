require "./spec_helper"

@[Kebab::Command(name: "start", summary: "Clock in")]
struct SubcommandSpecStart
  include Kebab::Parseable

  @[Kebab::Option(short: 'a')]
  getter at : String?

  @[Kebab::Option(short: 's')]
  getter? skip_validations : Bool = false
end

struct SubcommandSpecFinish
  include Kebab::Parseable

  getter at : String?
end

@[Kebab::Command(name: "break")]
struct SubcommandSpecBreak
  include Kebab::Parseable

  @[Kebab::Subcommand]
  getter command : SubcommandSpecStart | SubcommandSpecFinish
end

struct SubcommandSpecClock
  include Kebab::Parseable

  getter? verbose : Bool = false

  @[Kebab::Subcommand]
  getter command : SubcommandSpecStart | SubcommandSpecFinish | SubcommandSpecBreak
end

struct SubcommandSpecStrict
  include Kebab::Parseable

  @[Kebab::Subcommand(required: true)]
  getter command : SubcommandSpecStart | SubcommandSpecFinish
end

private def parse_clock!(args : Array(String)) : SubcommandSpecClock
  SubcommandSpecClock.parse(args).as(SubcommandSpecClock)
end

describe "Kebab::Parseable subcommands" do
  it "raises HelpRequested when no subcommand is given (default optionality)" do
    SubcommandSpecClock.parse([] of String).should be_a(Kebab::Help)
  end

  it "dispatches to a subcommand by its annotated name" do
    command = parse_clock!(["start"]).command
    command.should be_a(SubcommandSpecStart)
  end

  it "dispatches by the underscored type name when there is no annotation" do
    command = parse_clock!(["subcommand_spec_finish"]).command
    command.should be_a(SubcommandSpecFinish)
  end

  it "parses subcommand options with space-separated values (the cling bug)" do
    command = parse_clock!(["start", "--at", "8:45"]).command
    command.as(SubcommandSpecStart).at.should eq("8:45")
  end

  it "parses parent options before the subcommand" do
    clock = parse_clock!(["--verbose", "start", "-sa", "8:45"])

    clock.verbose?.should be_true
    start = clock.command.as(SubcommandSpecStart)
    start.skip_validations?.should be_true
    start.at.should eq("8:45")
  end

  it "dispatches nested subcommands" do
    command = parse_clock!(["break", "start", "--at", "1:00"]).command
    nested = command.as(SubcommandSpecBreak).command
    nested.as(SubcommandSpecStart).at.should eq("1:00")
  end

  it "errors on unknown commands listing candidates" do
    error = SubcommandSpecClock.parse(["strat"]).as(Kebab::Errors)
    error.should be_a(Kebab::Error::UnknownCommand)
    error.error_description.should eq("\"strat\" isn't a known command (expected one of: break, start, subcommand_spec_finish).")
  end

  it "propagates subcommand parse errors" do
    error = SubcommandSpecClock.parse(["start", "--nope"]).as(Kebab::Errors)
    error.should be_a(Kebab::Error::UnknownOption)
  end

  it "errors when a `required: true` subcommand is missing" do
    error = SubcommandSpecStrict.parse([] of String).as(Kebab::Errors)
    error.should be_a(Kebab::Error::MissingCommand)
    error.error_description.should eq("expected one of: start, subcommand_spec_finish.")
  end

  it "errors on parent options placed after the subcommand" do
    SubcommandSpecClock.parse(["start", "--verbose"]).as(Kebab::Errors).should be_a(Kebab::Error::UnknownOption)
  end

  it "treats `help` as a subcommand synonym for --help" do
    SubcommandSpecClock.parse(["help"]).should be_a(Kebab::Help)
  end

  it "auto-delegates `run(context)` to the chosen subcommand" do
    clock = parse_clock!(["start", "--at", "8:45"])
    seen = [] of String
    clock.run(seen)
    seen.should eq(["start:8:45"])
  end
end

# Test-only `run` overloads used by the auto-`run` spec — Array(String) is a
# unique-enough signature that it won't clash with anything else.
struct SubcommandSpecStart
  def run(seen : Array(String)) : Nil
    seen << "start:#{@at}"
  end
end

struct SubcommandSpecFinish
  def run(seen : Array(String)) : Nil
    seen << "finish"
  end
end

struct SubcommandSpecBreak
  def run(seen : Array(String)) : Nil
    @command.run(seen)
  end
end
