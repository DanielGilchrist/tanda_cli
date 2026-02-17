require "../../spec_helper"

describe TandaCLI::Commands::Auth::Logout do
  it "revokes token and clears authentication for production environment" do
    WebMock
      .stub(:post, "https://eu.tanda.co/api/oauth/revoke")
      .with(body: {token: "testtoken"}.to_json, headers: {"Content-Type" => "application/json"})
      .to_return(status: 200, body: "{}")

    context = run(["auth", "logout"])

    context.stdout.to_s.should contain("Revoking access token...")
    context.stdout.to_s.should contain("Revoked access token")
    context.stdout.to_s.should contain("Logged out of production environment")
    context.config.access_token.token.should be_nil
    context.config.access_token.email.should be_nil
    context.config.organisations.should be_empty
  end

  it "revokes token and clears authentication for staging environment" do
    WebMock
      .stub(:post, "https://staging.eu.tanda.co/api/oauth/revoke")
      .with(body: {token: "testtoken"}.to_json, headers: {"Content-Type" => "application/json"})
      .to_return(status: 200, body: "{}")

    context = run(["auth", "logout"], config_fixture: :default_staging)

    context.stdout.to_s.should contain("Revoking access token...")
    context.stdout.to_s.should contain("Revoked access token")
    context.stdout.to_s.should contain("Logged out of staging environment")
    context.config.access_token.token.should be_nil
    context.config.access_token.email.should be_nil
    context.config.organisations.should be_empty
  end

  it "warns but still clears authentication when revocation fails" do
    WebMock
      .stub(:post, "https://eu.tanda.co/api/oauth/revoke")
      .to_return(status: 503, body: "")

    context = run(["auth", "logout"])

    context.stdout.to_s.should contain("Revoking access token...")
    context.stdout.to_s.should_not contain("Revoked access token")
    context.stdout.to_s.should contain("Failed to revoke token (status: 503)")
    context.stdout.to_s.should contain("Logged out of production environment")
    context.config.access_token.token.should be_nil
  end
end
