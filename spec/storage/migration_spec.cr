require "../spec_helper"

private LEGACY_FIXTURE = "spec/fixtures/legacy/default.json"

private def in_temporary_home(& : String -> Nil) : Nil
  home = File.tempname("tanda_cli_home")
  Dir.mkdir_p(home)

  variables = {
    "HOME"                 => home,
    "TANDA_CLI_CONFIG_DIR" => "#{home}/config",
    "TANDA_CLI_DATA_DIR"   => "#{home}/data",
  } of String => String?

  with_environment(variables) do
    yield home
  end
ensure
  FileUtils.rm_rf(home.not_nil!) if home
end

private def write_legacy_config(home : String) : String
  directory = "#{home}/.tanda_cli"
  Dir.mkdir_p(directory)

  path = "#{directory}/config.json"
  File.write(path, File.read(LEGACY_FIXTURE))

  path
end

describe TandaCLI::Storage::Migration do
  it "Splits the legacy config into the config and state files" do
    in_temporary_home do |home|
      legacy_path = write_legacy_config(home)

      files = TandaCLI::Storage::Files.default

      production = TandaCLI::Configuration::Serialisable
        .parse?(files.environment(:production).read.not_nil!)
        .not_nil!
      production.start_of_week.should eq(Time::DayOfWeek::Saturday)
      production.treat_paid_breaks_as_unpaid?.should be_true
      production.regular_hours_schedules(1).size.should eq(5)

      files.environment(:staging).read.should be_nil

      state = TandaCLI::State::Serialisable.parse?(files.state.read.not_nil!).not_nil!
      state.current_environment.production?.should be_true

      environment = state.current
      environment.access_token.not_nil!.token.should eq("testtoken")
      environment.current_organisation?.not_nil!.name.should eq("Test Organisation")
      environment.as(TandaCLI::State::Serialisable::Environment::Production).region.eu?.should be_true

      File.exists?(legacy_path).should be_false
      Dir.exists?(File.dirname(legacy_path)).should be_false
    end
  end

  it "Leaves existing files alone" do
    in_temporary_home do |home|
      legacy_path = write_legacy_config(home)

      config_path = "#{home}/config/production.json"
      Dir.mkdir_p(File.dirname(config_path))
      File.write(config_path, %({"start_of_week":"monday"}))

      files = TandaCLI::Storage::Files.default

      files.environment(:production).read.should eq(%({"start_of_week":"monday"}))
      files.state.read.should be_nil
      File.exists?(legacy_path).should be_true
    end
  end

  it "Does nothing without a legacy config" do
    in_temporary_home do
      files = TandaCLI::Storage::Files.default

      files.environment(:production).read.should be_nil
      files.state.read.should be_nil
    end
  end
end
