require "../spec_helper"

describe TandaCLI::Commands::Mode do
  describe TandaCLI::Commands::Mode::Display do
    it "Shows the currently configured mode" do
      context = run(["mode", "display"])
      context.stdout.to_s.should eq("Mode is currently set to #{context.config.mode}\n")
    end
  end

  describe TandaCLI::Commands::Mode::Custom do
    it "Sets mode to a valid custom url" do
      url = "https://test.environment.tanda.co"
      context = run(["mode", "custom", url])

      context.config.mode.should eq(url)
      context.stdout.to_s.should eq("Success: Successfully set custom url \"#{url}\"\n")
    end

    it "Doesn't set mode if it's an invalid url" do
      url = "https://invalid_url.com"
      context = run(["mode", "custom", url])

      context.config.mode.should eq("production")
      context.stdout.to_s.should contain("Error: Host must contain")
    end
  end

  describe TandaCLI::Commands::Mode::Production do
    it "Sets mode to production" do
      context = run(["mode", "production"], config_fixture: :default_staging)
      context.config.mode.should eq("production")
      context.stdout.to_s.should eq("Success: Successfully set mode to production!\n")
    end
  end

  describe TandaCLI::Commands::Mode::Staging do
    it "Sets mode to staging" do
      context = run(["mode", "staging"])

      context.config.mode.should eq("staging")
      context.stdout.to_s.should eq("Success: Successfully set mode to staging!\n")
    end
  end
end
