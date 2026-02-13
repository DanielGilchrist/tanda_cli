require "../spec_helper"

describe TandaCLI::Commands::Me do
  it "outputs correctly on success" do
    WebMock
      .stub(:get, endpoint("/users/me"))
      .to_return(
        status: 200,
        body: {
          name:          "Harry Potter",
          email:         "harrypotter@hogwarts.com",
          country:       "United Kingdom",
          time_zone:     "Europe/London",
          user_ids:      [1],
          permissions:   ["wizard"],
          organisations: [
            {
              id:      1,
              name:    "Hogwarts",
              locale:  "en-GB",
              country: "United Kingdom",
              user_id: 1,
            },
          ],
        }.to_json
      )

    context = run(["me"])

    expected = <<-OUTPUT
    👤 Harry Potter
    📧 harrypotter@hogwarts.com
    🌍 United Kingdom
    🔑 Wizard

    🏢 Organisations:
        🏷 Hogwarts
        🌏 United Kingdom
        📍 en-GB

    OUTPUT

    context.stdout.to_s.should eq(expected)
  end

  it "outputs correctly on failure" do
    WebMock
      .stub(:get, endpoint("/users/me"))
      .to_return(
        status: 400,
        body: {
          error:             "Bad Request",
          error_description: "Something went wrong!",
        }.to_json
      )

    context = run(["me"])

    expected = <<-OUTPUT
    Error: Bad Request
           Something went wrong!

    OUTPUT

    context.stderr.to_s.should eq(expected)
  end
end
