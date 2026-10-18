require "./spec_helper"

describe TandaCLI::Context do
  it "Tells you to authenticate when there's no token" do
    context = run(["regular_hours", "display"], config_fixture: :unauthenticated)

    context.stderr.to_s.should contain("Not authenticated!")
    context.stderr.to_s.should contain("tanda_cli auth login")
    context.exit_status.should eq(1)
  end

  it "Tells you to pick a user when authenticated without a current one" do
    context = run(["regular_hours", "display"], config_fixture: :no_current_user)

    context.stderr.to_s.should contain("No current user set!")
    context.stderr.to_s.should contain("tanda_cli current_user set")
    context.exit_status.should eq(1)
  end
end
