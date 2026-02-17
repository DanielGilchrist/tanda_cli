require "../../spec_helper"

AUTH_TOKEN_BODY = {
  access_token: "faketoken",
  token_type:   "test",
  scope:        "me",
  created_at:   TandaCLI::Utils::Time.now.to_unix,
}.to_json

AUTH_FAILED_BODY = {
  error:             "invalid_grant",
  error_description: "The provided authorization grant is invalid",
}.to_json

private def stub_failed_auth(host : String)
  WebMock
    .stub(:post, "https://#{host}/api/oauth/token")
    .to_return(status: 401, body: AUTH_FAILED_BODY)
end

private def stub_successful_auth(host : String)
  WebMock
    .stub(:post, "https://#{host}/api/oauth/token")
    .to_return(status: 200, body: AUTH_TOKEN_BODY)
end

private def stub_all_regions_failed
  stub_failed_auth("my.workforce.com")
  stub_failed_auth("my.tanda.co")
  stub_failed_auth("eu.tanda.co")
end

private def stub_eu_auth_success
  stub_failed_auth("my.workforce.com")
  stub_failed_auth("my.tanda.co")
  stub_successful_auth("eu.tanda.co")
end

describe TandaCLI::Commands::Auth::Login do
  it "auto-detects region and prompts for organisation selection when multiple organisations" do
    stub_eu_auth_success

    WebMock
      .stub(:get, endpoint("/users/me"))
      .to_return(
        status: 200,
        body: {
          name:          "Test",
          email:         "test@example.com",
          country:       "United Kingdom",
          time_zone:     "Europe/London",
          user_ids:      [1, 2],
          permissions:   ["test"],
          organisations: [
            {
              id:      1,
              name:    "Test Organisation 1",
              locale:  "en-GB",
              country: "United Kingdom",
              user_id: 1,
            },
            {
              id:      2,
              name:    "Test Organisation 2",
              locale:  "en-GB",
              country: "United Kingdom",
              user_id: 2,
            },
          ],
        }.to_json
      )

    stdin = build_stdin(
      "test@example.com",
      "dummypassword",
      "2"
    )

    context = run(["auth", "login"], stdin: stdin)

    output = context.stdout.to_s
    output.should contain("Tanda CLI Login")
    output.should contain("Email:")
    output.should contain("Password:")
    output.should contain("Authenticating...")
    output.should contain("Authenticated!")
    output.should contain("Select an organisation:")
    output.should contain("Test Organisation 1")
    output.should contain("Test Organisation 2")
    output.should contain("Selected organisation \"Test Organisation 2\"")
    output.should contain("Organisations saved to config")
  end

  it "auto-selects organisation when only one is available" do
    stub_eu_auth_success

    WebMock
      .stub(:get, endpoint("/users/me"))
      .to_return(
        status: 200,
        body: {
          name:          "Test",
          email:         "test@example.com",
          country:       "United Kingdom",
          time_zone:     "Europe/London",
          user_ids:      [1],
          permissions:   ["test"],
          organisations: [
            {
              id:      1,
              name:    "Test Organisation",
              locale:  "en-GB",
              country: "United Kingdom",
              user_id: 1,
            },
          ],
        }.to_json
      )

    stdin = build_stdin(
      "test@example.com",
      "dummypassword",
    )

    context = run(["auth", "login"], stdin: stdin)

    output = context.stdout.to_s
    output.should contain("Authenticated!")
    output.should contain("Selected organisation \"Test Organisation\"")
    output.should contain("Organisations saved to config")
  end

  it "errors when all regions fail authentication" do
    stub_all_regions_failed

    stdin = build_stdin(
      "bad@example.com",
      "wrongpassword",
    )

    context = run(["auth", "login"], stdin: stdin)

    context.stderr.to_s.should contain("Unable to authenticate")
  end

  it "stops at the first successful region" do
    stub_successful_auth("my.workforce.com")

    WebMock
      .stub(:get, "https://my.workforce.com/api/v2/users/me")
      .to_return(
        status: 200,
        body: {
          name:          "Test",
          email:         "test@example.com",
          country:       "Australia",
          time_zone:     "Australia/Sydney",
          user_ids:      [1],
          permissions:   ["test"],
          organisations: [
            {
              id:      1,
              name:    "Test Organisation",
              locale:  "en-AU",
              country: "Australia",
              user_id: 1,
            },
          ],
        }.to_json
      )

    stdin = build_stdin(
      "test@example.com",
      "dummypassword",
    )

    context = run(["auth", "login"], stdin: stdin)

    output = context.stdout.to_s
    output.should contain("Authenticated!")
  end
end
