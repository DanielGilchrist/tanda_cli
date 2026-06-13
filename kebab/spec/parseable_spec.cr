require "./spec_helper"

struct SpecDuration
  def self.parse(input : String) : self | Kebab::Error::InvalidValue
    if minutes = input.to_i32?
      new(minutes)
    else
      Kebab.invalid_value("expected a duration in minutes")
    end
  end

  def initialize(@minutes : Int32); end

  getter minutes : Int32
end

module UpcaseConverter
  def self.parse(input : String) : String | Kebab::Error::InvalidValue
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

private struct ConstantDefault
  include Kebab::Parseable

  MAX_WEEKS = 52

  @[Kebab::Option]
  getter weeks : Int32 = MAX_WEEKS
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

  it "errors on a repeated long option" do
    error = parse_punch_error!(["--at", "8:45", "--at", "9:30"])
    error.should be_a(Kebab::Error::RepeatedOption)
    error.error_description.should eq("\"--at\" was given more than once.")
  end

  it "errors on a repeated short option" do
    parse_punch_error!(["-a", "8:45", "-a", "9:30"]).should be_a(Kebab::Error::RepeatedOption)
  end

  it "errors on a repeated flag" do
    parse_punch_error!(["--verbose", "--verbose"]).should be_a(Kebab::Error::RepeatedOption)
  end

  it "errors on an empty short cluster" do
    error = parse_punch_error!(["-=foo"])
    error.should be_a(Kebab::Error::UnknownOption)
    error.error_description.should eq("\"-\" isn't a recognised option.")
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

  it "resolves constants defined on the including struct as defaults" do
    ConstantDefault.parse([] of String).as(ConstantDefault).weeks.should eq(52)
  end

  it "exposes the option name on UnknownOption" do
    error = parse_punch_error!(["--nope"]).as(Kebab::Error::UnknownOption)
    error.option.should eq("--nope")
  end

  it "exposes the option name on MissingValue" do
    error = parse_punch_error!(["--at"]).as(Kebab::Error::MissingValue)
    error.option.should eq("--at")
  end

  it "exposes the option name on RepeatedOption" do
    error = parse_punch_error!(["--at", "8:45", "--at", "9:30"]).as(Kebab::Error::RepeatedOption)
    error.option.should eq("--at")
  end

  it "exposes the argument name on MissingArgument" do
    error = Trim.parse([] of String).as(Kebab::Error::MissingArgument)
    error.argument.should eq("path")
  end

  it "exposes the option name on MissingOption" do
    error = RequiredOption.parse([] of String).as(Kebab::Error::MissingOption)
    error.option.should eq("--token")
  end

  it "exposes the raw value on UnexpectedArgument" do
    error = parse_punch_error!(["wat"]).as(Kebab::Error::UnexpectedArgument)
    error.value.should eq("wat")
  end

  it "exposes option, value, and reason on InvalidValue" do
    error = parse_punch_error!(["--weeks", "potato"]).as(Kebab::Error::InvalidValue)
    error.option.should eq("--weeks")
    error.value.should eq("potato")
    error.reason.should eq("expected a number (Int32)")
  end
end

enum SpecOutputFormat
  Json
  Yaml
  Text
end

private struct EnumHaver
  include Kebab::Parseable

  @[Kebab::Option(converter: Kebab::Convert::Enum(SpecOutputFormat))]
  getter format : SpecOutputFormat = SpecOutputFormat::Text
end

describe Kebab::Convert::Enum do
  it "parses a matching enum value (case-insensitive)" do
    EnumHaver.parse(["--format", "json"]).as(EnumHaver).format.should eq(SpecOutputFormat::Json)
    EnumHaver.parse(["--format", "YAML"]).as(EnumHaver).format.should eq(SpecOutputFormat::Yaml)
  end

  it "uses the default when not given" do
    EnumHaver.parse([] of String).as(EnumHaver).format.should eq(SpecOutputFormat::Text)
  end

  it "errors with the valid names when unrecognised" do
    error = EnumHaver.parse(["--format", "xml"]).as(Kebab::Error::InvalidValue)
    error.reason.should eq("expected one of: json, yaml, text")
    error.option.should eq("--format")
    error.value.should eq("xml")
  end
end
