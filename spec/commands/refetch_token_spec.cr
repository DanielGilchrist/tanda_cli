require "../spec_helper"

describe TandaCLI::Commands::RefetchToken do
  it "outputs correctly on success" do
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

    context = run(["refetch_token"], stdin: stdin)

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
end
