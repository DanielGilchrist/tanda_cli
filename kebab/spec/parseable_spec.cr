require "./spec_helper"

struct SpecDuration
  def self.parse(input : String) : self | Kebab::Error::Unparseable
    if minutes = input.to_i32?
      new(minutes)
    else
      Kebab.parse_error("expected a duration in minutes")
    end
  end

  def initialize(@minutes : Int32); end

  getter minutes : Int32
end

module UpcaseConverter
  def self.parse(input : String) : String | Kebab::Error::Unparseable
    input.upcase
  end
end

private struct Punch
  include Kebab::Parseable

  @[Kebab::Option(short: 'a', description: "Clock in at a past time")]
  getter at : String?

  @[Kebab::Option(short: 's')]
  getter? skip_validations : Bool = false

  @[Kebab::Option]
  getter? verbose : Bool = false

  @[Kebab::Option]
  getter weeks : Int32 = 4

  @[Kebab::Option(converter: UpcaseConverter)]
  getter shout : String?

  @[Kebab::Option(long: "duration")]
  getter pause : SpecDuration?
end

private struct Trim
  include Kebab::Parseable

  @[Kebab::Argument]
  getter path : String

  @[Kebab::Argument]
  getter limit : Int32 = 10
end

private struct ConvertedArg
  include Kebab::Parseable

  @[Kebab::Argument(converter: UpcaseConverter)]
  getter value : String
end

private struct RequiredOption
  include Kebab::Parseable

  @[Kebab::Option]
  getter token : String
end

private struct FloatHaver
  include Kebab::Parseable

  @[Kebab::Option]
  getter ratio : Float64 = 0.5
end

private def parse_punch!(args : Array(String)) : Punch
  Punch.parse(args).as(Punch)
end

private def parse_punch_error!(args : Array(String)) : Kebab::Errors
  Punch.parse(args).as(Kebab::Errors)
end

describe Kebab::Parseable do
  it "defaults everything with no args" do
    punch = parse_punch!([] of String)

    punch.at.should be_nil
    punch.skip_validations?.should be_false
    punch.verbose?.should be_false
    punch.weeks.should eq(4)
    punch.pause.should be_nil
  end

  it "parses space-separated long option values" do
    parse_punch!(["--at", "8:45"]).at.should eq("8:45")
  end

  it "parses inline long option values" do
    parse_punch!(["--at=8:45"]).at.should eq("8:45")
  end

  it "parses short option values" do
    parse_punch!(["-a", "8:45"]).at.should eq("8:45")
    parse_punch!(["-a=8:45"]).at.should eq("8:45")
  end

  it "parses long flags" do
    parse_punch!(["--verbose"]).verbose?.should be_true
  end

  it "kebab-cases multi-word ivar names into long flags" do
    parse_punch!(["--skip-validations"]).skip_validations?.should be_true
  end

  it "parses short flags and clusters" do
    parse_punch!(["-s"]).skip_validations?.should be_true

    punch = parse_punch!(["-sa", "8:45"])
    punch.skip_validations?.should be_true
    punch.at.should eq("8:45")
  end

  it "converts built-in number types" do
    parse_punch!(["--weeks", "12"]).weeks.should eq(12)
  end

  it "converts custom types via the parse protocol" do
    pause = parse_punch!(["--duration", "30"]).pause
    pause.should eq(SpecDuration.new(30))
  end

  it "applies converter overrides" do
    parse_punch!(["--shout", "hello"]).shout.should eq("HELLO")
  end

  it "errors on unknown long options" do
    error = parse_punch_error!(["--nope"])
    error.should be_a(Kebab::Error::UnknownOption)
    error.error_description.should eq("\"--nope\" isn't a recognised option.")
  end

  it "errors on unknown short options" do
    parse_punch_error!(["-z"]).should be_a(Kebab::Error::UnknownOption)
  end

  it "errors when a value is missing" do
    parse_punch_error!(["--at"]).should be_a(Kebab::Error::MissingValue)
    parse_punch_error!(["--at", "--verbose"]).should be_a(Kebab::Error::MissingValue)
  end

  it "errors when a valued short option is not last in a cluster" do
    parse_punch_error!(["-as", "8:45"]).should be_a(Kebab::Error::MissingValue)
  end

  it "errors when a built-in conversion fails" do
    error = parse_punch_error!(["--weeks", "potato"])
    error.should be_a(Kebab::Error::InvalidValue)
    error.error_description.should eq("\"potato\" isn't a valid value for \"--weeks\" (expected a number (Int32))")
  end

  it "errors when a custom conversion fails" do
    error = parse_punch_error!(["--duration", "potato"])
    error.should be_a(Kebab::Error::InvalidValue)
    error.error_description.should eq("\"potato\" isn't a valid value for \"--duration\" (expected a duration in minutes)")
  end

  it "errors when a flag is given an inline value" do
    parse_punch_error!(["--verbose=true"]).should be_a(Kebab::Error::InvalidValue)
  end

  it "errors on unexpected positionals" do
    parse_punch_error!(["wat"]).should be_a(Kebab::Error::UnexpectedArgument)
  end

  it "treats everything after -- as positional" do
    parse_punch_error!(["--", "--verbose"]).should be_a(Kebab::Error::UnexpectedArgument)
  end

  it "binds positional arguments in declaration order" do
    trim = Trim.parse(["src/thing.cr", "5"]).as(Trim)
    trim.path.should eq("src/thing.cr")
    trim.limit.should eq(5)
  end

  it "defaults optional positional arguments" do
    trim = Trim.parse(["src/thing.cr"]).as(Trim)
    trim.limit.should eq(10)
  end

  it "errors when a required positional argument is missing" do
    error = Trim.parse([] of String).as(Kebab::Errors)
    error.should be_a(Kebab::Error::MissingArgument)
    error.error_description.should eq("\"path\" is required.")
  end

  it "accepts option values after the -- separator as positionals" do
    trim = Trim.parse(["--", "--weird-filename"]).as(Trim)
    trim.path.should eq("--weird-filename")
  end

  it "last-write-wins for repeated options" do
    parse_punch!(["--at", "8:45", "--at", "9:30"]).at.should eq("9:30")
  end

  it "errors when an option value looks like another option" do
    error = parse_punch_error!(["--at", "-3"])
    error.should be_a(Kebab::Error::MissingValue)
  end

  it "accepts negative-looking values via the inline = form" do
    parse_punch!(["--at=-3"]).at.should eq("-3")
  end

  it "errors when a required option is missing" do
    error = RequiredOption.parse([] of String).as(Kebab::Errors)
    error.should be_a(Kebab::Error::MissingOption)
    error.error_description.should eq("\"--token\" is required.")
  end

  it "applies a converter to a positional argument" do
    ConvertedArg.parse(["hello"]).as(ConvertedArg).value.should eq("HELLO")
  end

  it "converts floats" do
    FloatHaver.parse(["--ratio", "0.25"]).as(FloatHaver).ratio.should eq(0.25)
  end

  it "errors on integer overflow" do
    error = parse_punch_error!(["--weeks", "99999999999999999999"])
    error.should be_a(Kebab::Error::InvalidValue)
  end
end
