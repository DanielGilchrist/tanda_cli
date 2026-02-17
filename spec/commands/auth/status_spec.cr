require "../../spec_helper"

describe TandaCLI::Commands::Auth::Status do
  it "displays authenticated status with details" do
    context = run(["auth", "status"])

    output = context.stdout.to_s
    output.should contain("Authenticated (production)")
    output.should contain("test@testmailfakenotrealthisisntarealdomainaaaa.com")
    output.should contain("Test Organisation (user 1)")
    output.should contain("eu")
  end

  it "displays authenticated status in staging" do
    context = run(["auth", "status"], config_fixture: :default_staging)

    output = context.stdout.to_s
    output.should contain("Authenticated (staging)")
  end

  it "displays not authenticated when no token" do
    context = run(["auth", "status"], config_fixture: :unauthenticated)

    output = context.stdout.to_s
    output.should contain("Not authenticated (production)")
    output.should contain("Run `tanda_cli auth login` to authenticate")
  end
end
