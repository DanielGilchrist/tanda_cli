require "../../spec_helper"

describe TandaCLI::Commands::Auth::Login do
  it "logs in and prompts for organisation selection when multiple organisations" do
    scope = "me"

    WebMock
      .stub(:post, "https://eu.tanda.co/api/oauth/token")
      .to_return(
        status: 200,
        body: {
          access_token: "faketoken",
          token_type:   "test",
          scope:        scope,
          created_at:   TandaCLI::Utils::Time.now.to_unix,
        }.to_json
      )

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
      "eu",
      "test@example.com",
      "dummypassword",
      "2"
    )

    context = run(["auth", "login"], stdin: stdin)

    expected = <<-OUTPUT
    Site prefix (my, eu, us - Default is "my"):

    What's your email?

    What's your password?

    Success: Retrieved token!
    Which organisation would you like to use?
    1: Test Organisation 1
    2: Test Organisation 2

    Enter a number:
    Success: Selected organisation "Test Organisation 2"
    Success: Organisations saved to config

    OUTPUT

    context.stdout.to_s.should eq(expected)
  end

  it "auto-selects organisation when only one is available" do
    WebMock
      .stub(:post, "https://eu.tanda.co/api/oauth/token")
      .to_return(
        status: 200,
        body: {
          access_token: "faketoken",
          token_type:   "test",
          scope:        "me",
          created_at:   TandaCLI::Utils::Time.now.to_unix,
        }.to_json
      )

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
      "eu",
      "test@example.com",
      "dummypassword",
    )

    context = run(["auth", "login"], stdin: stdin)

    expected = <<-OUTPUT
    Site prefix (my, eu, us - Default is "my"):

    What's your email?

    What's your password?

    Success: Retrieved token!
    Success: Selected organisation "Test Organisation"
    Success: Organisations saved to config

    OUTPUT

    context.stdout.to_s.should eq(expected)
  end

  it "errors with invalid credentials" do
    WebMock
      .stub(:post, "https://eu.tanda.co/api/oauth/token")
      .to_return(
        status: 401,
        body: {
          error:             "invalid_grant",
          error_description: "The provided authorization grant is invalid",
        }.to_json
      )

    stdin = build_stdin(
      "eu",
      "bad@example.com",
      "wrongpassword",
    )

    context = run(["auth", "login"], stdin: stdin)

    context.stderr.to_s.should contain("Unable to authenticate")
  end
end
