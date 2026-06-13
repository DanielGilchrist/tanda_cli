require "./spec_helper"

@[Kebab::Command(name: "start", summary: "Clock in")]
struct SubcommandSpecStart
  include Kebab::Serialisable

  @[Kebab::Option(short: 'a')]
  getter at : String?

  @[Kebab::Option(short: 's')]
  getter? skip_validations : Bool = false
end

struct SubcommandSpecFinish
  include Kebab::Serialisable

  getter at : String?
end

@[Kebab::Command(name: "break")]
struct SubcommandSpecBreak
  include Kebab::Serialisable

  @[Kebab::Subcommand]
  getter command : SubcommandSpecStart | SubcommandSpecFinish | Nil
end

struct SubcommandSpecClock
  include Kebab::Serialisable

  getter? verbose : Bool = false

  @[Kebab::Subcommand]
  getter command : SubcommandSpecStart | SubcommandSpecFinish | SubcommandSpecBreak | Nil
end

struct SubcommandSpecStrict
  include Kebab::Serialisable

  @[Kebab::Subcommand]
  getter command : SubcommandSpecStart | SubcommandSpecFinish
end

private def parse_clock!(args : Array(String)) : SubcommandSpecClock
  SubcommandSpecClock.parse(args).as(SubcommandSpecClock)
end

describe "Kebab::Serialisable subcommands" do
  it "is nil when no subcommand is given and the field is nilable" do
    parse_clock!([] of String).command.should be_nil
  end

  it "dispatches to a subcommand by its annotated name" do
    command = parse_clock!(["start"]).command
    command.should be_a(SubcommandSpecStart)
  end

  it "dispatches by the kebab-cased type name when there is no annotation" do
    command = parse_clock!(["subcommand-spec-finish"]).command
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
    error = SubcommandSpecClock.parse(["strat"]).as(Kebab::Error::Base)
    error.should be_a(Kebab::Error::UnknownCommand)
    error.error_description.should eq("\"strat\" isn't a known command (expected one of: break, start, subcommand-spec-finish).")
  end

  it "propagates subcommand parse errors" do
    error = SubcommandSpecClock.parse(["start", "--nope"]).as(Kebab::Error::Base)
    error.should be_a(Kebab::Error::UnknownOption)
  end

  it "errors when a required subcommand is missing" do
    error = SubcommandSpecStrict.parse([] of String).as(Kebab::Error::Base)
    error.should be_a(Kebab::Error::MissingCommand)
    error.error_description.should eq("expected one of: start, subcommand-spec-finish.")
  end

  it "errors on parent options placed after the subcommand" do
    SubcommandSpecClock.parse(["start", "--verbose"]).as(Kebab::Error::Base).should be_a(Kebab::Error::UnknownOption)
  end
end
