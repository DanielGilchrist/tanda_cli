require "../spec_helper"

describe TandaCLI::Storage::Paths do
  it "Defaults to the XDG directories" do
    with_environment({
      "HOME"                 => "/home/tester",
      "XDG_CONFIG_HOME"      => nil,
      "XDG_DATA_HOME"        => nil,
      "TANDA_CLI_CONFIG_DIR" => nil,
      "TANDA_CLI_DATA_DIR"   => nil,
    }) do
      TandaCLI::Storage::Paths.environment_file(:production).to_s.should eq("/home/tester/.config/tanda_cli/production.json")
      TandaCLI::Storage::Paths.state_file.to_s.should eq("/home/tester/.local/share/tanda_cli/state.json")
    end
  end

  it "Follows XDG_CONFIG_HOME and XDG_DATA_HOME" do
    with_environment({
      "HOME"                 => "/home/tester",
      "XDG_CONFIG_HOME"      => "/elsewhere/config",
      "XDG_DATA_HOME"        => "/elsewhere/data",
      "TANDA_CLI_CONFIG_DIR" => nil,
      "TANDA_CLI_DATA_DIR"   => nil,
    }) do
      TandaCLI::Storage::Paths.environment_file(:staging).to_s.should eq("/elsewhere/config/tanda_cli/staging.json")
      TandaCLI::Storage::Paths.state_file.to_s.should eq("/elsewhere/data/tanda_cli/state.json")
    end
  end

  it "Prefers the application variables and doesn't append the application name to them" do
    with_environment({
      "HOME"                 => "/home/tester",
      "XDG_CONFIG_HOME"      => "/elsewhere/config",
      "XDG_DATA_HOME"        => "/elsewhere/data",
      "TANDA_CLI_CONFIG_DIR" => "~/tanda/config",
      "TANDA_CLI_DATA_DIR"   => "/var/tanda",
    }) do
      TandaCLI::Storage::Paths.environment_file(:custom).to_s.should eq("/home/tester/tanda/config/custom.json")
      TandaCLI::Storage::Paths.state_file.to_s.should eq("/var/tanda/state.json")
    end
  end

  it "Points at the old location for the legacy config" do
    with_environment({"HOME" => "/home/tester"}) do
      TandaCLI::Storage::Paths.legacy_config_file.to_s.should eq("/home/tester/.tanda_cli/config.json")
    end
  end
end
