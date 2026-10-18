require "../spec_helper"

private alias Environments = TandaCLI::State::Serialisable::Environments

describe TandaCLI::Commands::Mode do
  describe TandaCLI::Commands::Mode::Display do
    it "Shows the currently configured mode" do
      context = run(["mode", "display"])
      context.stdout.to_s.should eq("Production\n")
    end
  end

  describe TandaCLI::Commands::Mode::Custom do
    it "Sets mode to a valid custom url" do
      url = "https://test.environment.tanda.co"
      context = run(["mode", "custom", url])

      env = context.state.current
      env.should be_a(Environments::Custom)
      env.as(Environments::Custom).url.to_s.should eq(url)
      context.stdout.to_s.should eq("Success: Successfully set custom url \"#{url}\"\n")
    end

    it "Sets mode to a valid custom .adnat.co url" do
      url = "https://dangilchrist.dev.us.adnat.co"
      context = run(["mode", "custom", url])

      env = context.state.current
      env.should be_a(Environments::Custom)
      env.as(Environments::Custom).url.to_s.should eq(url)
    end

    it "Doesn't set mode if it's an invalid url" do
      url = "https://invalid_url.com"
      context = run(["mode", "custom", url])

      context.state.current.should be_a(Environments::Production)
      context.stderr.to_s.should contain("Error: Host must end with")
    end

    it "Doesn't set mode if a valid host suffix only appears in the middle of the host" do
      url = "https://my.tanda.co.attacker.com"
      context = run(["mode", "custom", url])

      context.state.current.should be_a(Environments::Production)
      context.stderr.to_s.should contain("Error: Host must end with")
    end
  end

  describe TandaCLI::Commands::Mode::Production do
    it "Sets mode to production" do
      context = run(["mode", "production"], config_fixture: :default_staging)
      context.state.current.should be_a(Environments::Production)
      context.stdout.to_s.should eq("Success: Successfully set mode to production!\n")
    end
  end

  describe TandaCLI::Commands::Mode::Staging do
    it "Sets mode to staging" do
      context = run(["mode", "staging"])

      context.state.current.should be_a(Environments::Staging)
      context.stdout.to_s.should eq("Success: Successfully set mode to staging!\n")
    end
  end
end
