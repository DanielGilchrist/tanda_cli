require "../spec_helper"

describe TandaCLI::Commands::PersonalDetails do
  it "outputs correctly on success" do
    WebMock
      .stub(:get, endpoint("/personal_details"))
      .to_return(
        status: 200,
        body: {
          email: "harrypotter@hogwarts.com",
          gender: nil,
          emergency_contacts: [
            {
              id: 1,
              name: "Ronald Weasley",
              phone: "+440000000000",
              relationship: "Friend"
            },
            {
              id: 2,
              name: "Ronald Weasley",
              phone: "+440000000000",
              relationship: "Friend"
            }
          ],
          residential_address: {
            street_line_one: "4 Privet Drive",
            street_line_two: "Little Whinging",
            city: "Surrey",
            state: "England",
            country: "United Kingdom",
            postcode: "GU4 8HS"
          },
          updated_at: 1734525270
        }.to_json
      )

    io, _context = run_command(["personal_details"])

    expected = <<-OUTPUT
    📖 Personal Details
    📧 harrypotter@hogwarts.com

    🚑 Emergency Contacts
    🏷 Ronald Weasley
    👥 Friend
    📞 +440000000000

    🏠 Address
    4 Privet Drive, Little Whinging, Surrey, England, GU4 8HS, United Kingdom


    OUTPUT

    io.to_s.should eq(expected)
  end

  it "outputs correctly on failure" do
    WebMock
      .stub(:get, endpoint("/personal_details"))
      .to_return(
        status: 400,
        body: {
          error:             "Bad Request",
          error_description: "Something went wrong!",
        }.to_json
      )

    io, _context = run_command(["personal_details"])

    expected = <<-OUTPUT
    Error: Bad Request
           Something went wrong!

    OUTPUT

    io.to_s.should eq(expected)
  end
end
