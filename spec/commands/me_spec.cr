require "json"
require "../spec_helper"

Spectator.describe TandaCLI::Current do
  it "outputs correctly on success" do
    WebMock
      .stub(:get, "https://eu.tanda.co/api/v2/users/me")
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

    output = with_command_output do
      TandaCLI.main(["me"])
    end

    expected = <<-OUTPUT
    👤 Harry Potter
    📧 harrypotter@hogwarts.com
    🌍 United Kingdom
    ⏰ Europe/London
    🔑 Wizard

    🏢 Organisations:
        🏷  Hogwarts
        🌏 United Kingdom
        📍 en-GB


    OUTPUT

    expect(output).to eq(expected)
  end

  it "outputs correctly on failure" do
    WebMock
      .stub(:get, "https://eu.tanda.co/api/v2/users/me")
      .to_return(
        status: 400,
        body: {
          error:             "Bad Request",
          error_description: "Something went wrong!",
        }.to_json
      )

    output = with_command_output do
      TandaCLI.main(["me"])
    end

    expected = <<-OUTPUT
    Error: Bad Request
           Something went wrong!

    OUTPUT

    expect(output).to eq(expected)
  end
end
