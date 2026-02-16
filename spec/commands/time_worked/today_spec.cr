require "../../spec_helper"

describe TandaCLI::Commands::TimeWorked::Today do
  it "Displays time worked for today" do
    WebMock
      .stub(:get, endpoint(Regex.new("/shifts")))
      .to_return(
        status: 200,
        body: [
          build_shift(
            id: 1,
            start: Time.local(2024, 12, 23, 8, 30),
            finish: Time.local(2024, 12, 23, 17),
            break_start: Time.local(2024, 12, 23, 12),
            break_finish: Time.local(2024, 12, 23, 12, 30)
          ),
        ].to_json,
      )

    travel_to(Time.local(2024, 12, 24)) do
      context = run(["time_worked", "today"])
      context.stdout.to_s.should eq("You've worked 8 hours and 0 minutes today\n")
    end
  end

  it "Displays time worked for today displaying shifts when --display flag is passed" do
    WebMock
      .stub(:get, endpoint(Regex.new("/shifts")))
      .to_return(
        status: 200,
        body: [
          build_shift(
            id: 1,
            start: Time.local(2024, 12, 23, 8, 30),
            finish: Time.local(2024, 12, 23, 17),
            break_start: Time.local(2024, 12, 23, 12),
            break_finish: Time.local(2024, 12, 23, 12, 30)
          ),
        ].to_json,
      )

    travel_to(Time.local(2024, 12, 24, 14)) do
      context = run(["time_worked", "today", "--display"])

      expected = <<-OUTPUT.gsub("<space>", " ")
      Time worked: 8 hours and 0 minutes
      📅 Monday, 23 Dec 2024
      🕓 8:30 am - 5:00 pm
      🚧 Pending
      ☕️ Breaks:
          🕓 12:00 pm - 12:30 pm
          ⏸️  30 minutes
          💰 false

      You've worked 8 hours and 0 minutes today

      OUTPUT

      context.stdout.to_s.should eq(expected)
    end
  end
end

private def build_shift(id, start, finish, break_start, break_finish)
  {
    id:           id,
    timesheet_id: 1,
    user_id:      1,
    date:         TandaCLI::Utils::Time.iso_date(start),
    start:        start.try(&.to_unix),
    break_start:  break_start.try(&.to_unix),
    break_finish: break_finish.try(&.to_unix),
    break_length: 30,
    breaks:       [
      {
        id:                               1,
        selected_automatic_break_rule_id: nil,
        shift_id:                         id,
        start:                            break_start.try(&.to_unix),
        finish:                           break_finish.try(&.to_unix),
        length:                           30,
        paid:                             false,
        updated_at:                       1735259689,
      },
    ],
    finish:           finish.try(&.to_unix),
    department_id:    1,
    sub_cost_centre:  nil,
    tag:              nil,
    tag_id:           nil,
    status:           "PENDING",
    metadata:         nil,
    leave_request_id: nil,
    allowances:       [] of Hash(String, String),
    approved_by:      nil,
    approved_at:      nil,
    notes:            [] of Hash(String, String),
    updated_at:       1735259689,
    record_id:        1,
  }
end
