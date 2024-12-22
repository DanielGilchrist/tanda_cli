require "../spec_helper"

describe TandaCLI::Commands::Balance do
  it "Fetches and displays leave balance info" do
    WebMock
      .stub(:get, endpoint("/leave_balances", {
        "user_ids" => "1",
      }))
      .to_return(
        status: 200,
        body: [
          {
            id:            1,
            user_id:       1,
            leave_type:    "Holiday Leave",
            hours:         128.0,
            should_accrue: true,
            updated_at:    1704219040,
          },
          {
            id:            2,
            user_id:       1,
            leave_type:    "Sick Leave",
            hours:         40.0,
            should_accrue: true,
            updated_at:    1704219040,
          },
        ]
          .to_json,
      )

    context = Command.run(["balance"])

    expected = <<-OUTPUT
    Leave Balance
        ⏳ 128.0 hours
        🌴 Holiday Leave


    OUTPUT

    context.io.to_s.should eq(expected)
  end
end
