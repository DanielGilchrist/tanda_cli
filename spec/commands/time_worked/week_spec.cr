require "../../spec_helper"

describe TandaCLI::Commands::TimeWorked::Week do
  it "Displays time worked for the week" do
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
          build_shift(
            id: 2,
            start: Time.local(2024, 12, 24, 8, 30),
            finish: Time.local(2024, 12, 24, 17),
            break_start: Time.local(2024, 12, 24, 12),
            break_finish: Time.local(2024, 12, 24, 12, 30)
          ),
        ].to_json,
      )

    travel_to(Time.local(2024, 12, 24)) do
      context = run(["time_worked", "week"])
      context.stdout.to_s.should eq("You've worked 16 hours and 0 minutes this week\n")
    end
  end

  it "Displays time worked for week displaying shifts when --display flag is passed" do
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
          build_shift(
            id: 2,
            start: Time.local(2024, 12, 24, 8, 30),
            finish: nil,
            break_start: Time.local(2024, 12, 24, 12),
            break_finish: Time.local(2024, 12, 24, 12, 30)
          ),
        ].to_json,
      )

    travel_to(Time.local(2024, 12, 24, 14)) do
      context = run(["time_worked", "week", "--display"])

      expected = <<-OUTPUT.gsub("<space>", " ")
      Time worked: 8 hours and 0 minutes
      📅 Monday, 23 Dec 2024
      🕓 8:30 am - 5:00 pm
      🚧 Pending
      ☕️ Breaks:
          🕓 12:00 pm - 12:30 pm
          ⏸️  30 minutes
          💰 false

      Worked so far: 5 hours and 0 minutes
      📅 Tuesday, 24 Dec 2024
      🕓 8:30 am -<space>
      🚧 Pending
      ☕️ Breaks:
          🕓 12:00 pm - 12:30 pm
          ⏸️  30 minutes
          💰 false

      Time left today: 3 hours and 0 minutes
      You can clock out at: 5:00 pm

      You've worked 13 hours and 0 minutes this week

      OUTPUT

      context.stdout.to_s.should eq(expected)
    end
  end

  it "Does not assume a scheduled break for a second shift on the same day when breaks have already been taken" do
    WebMock
      .stub(:get, endpoint(Regex.new("/shifts")))
      .to_return(
        status: 200,
        body: [
          build_shift(
            id: 1,
            start: Time.local(2024, 12, 23, 8, 41),
            finish: Time.local(2024, 12, 23, 15, 1),
            break_start: Time.local(2024, 12, 23, 12, 4),
            break_finish: Time.local(2024, 12, 23, 12, 51)
          ),
          build_shift_without_breaks(
            id: 2,
            start: Time.local(2024, 12, 23, 16, 27),
            finish: nil
          ),
        ].to_json,
      )

    travel_to(Time.local(2024, 12, 23, 17, 20)) do
      context = run(["time_worked", "week", "--display"])

      expected = <<-OUTPUT.gsub("<space>", " ")
      Time worked: 5 hours and 50 minutes
      📅 Monday, 23 Dec 2024
      🕓 8:41 am - 3:01 pm
      🚧 Pending
      ☕️ Breaks:
          🕓 12:04 pm - 12:51 pm
          ⏸️  30 minutes
          💰 false

      Worked so far: 0 hours and 53 minutes
      📅 Monday, 23 Dec 2024
      🕓 4:27 pm -<space>
      🚧 Pending

      Time left today: 1 hours and 17 minutes
      You can clock out at: 6:37 pm

      You've worked 6 hours and 43 minutes this week

      OUTPUT

      context.stdout.to_s.should eq(expected)
    end
  end

  it "Displays leave taken for the week" do
    leave_request_id = 100

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
          build_leave_shift(
            id: 3,
            date: Time.local(2024, 12, 25),
            leave_request_id: leave_request_id,
          ),
        ].to_json,
      )

    WebMock
      .stub(:get, endpoint(Regex.new("/leave")))
      .to_return(
        status: 200,
        body: [
          build_leave_request(
            id: leave_request_id,
            shift_id: 3,
            date: "2024-12-25",
            hours: 8.0,
          ),
        ].to_json,
      )

    travel_to(Time.local(2024, 12, 25)) do
      context = run(["time_worked", "week"])
      expected = <<-OUTPUT
      You've worked 8 hours and 0 minutes this week
      You've taken 8 hours and 0 minutes of leave this week

      OUTPUT

      context.stdout.to_s.should eq(expected)
    end
  end

  it "Displays leave taken with --display flag" do
    leave_request_id = 100

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
          build_leave_shift(
            id: 3,
            date: Time.local(2024, 12, 25),
            leave_request_id: leave_request_id,
          ),
        ].to_json,
      )

    WebMock
      .stub(:get, endpoint(Regex.new("/leave")))
      .to_return(
        status: 200,
        body: [
          build_leave_request(
            id: leave_request_id,
            shift_id: 3,
            date: "2024-12-25",
            hours: 8.0,
            leave_type: "Holiday Leave",
            status: "approved",
            reason: "Christmas Day",
          ),
        ].to_json,
      )

    travel_to(Time.local(2024, 12, 25)) do
      context = run(["time_worked", "week", "--display"])

      expected = <<-OUTPUT
      Time worked: 8 hours and 0 minutes
      📅 Monday, 23 Dec 2024
      🕓 8:30 am - 5:00 pm
      🚧 Pending
      ☕️ Breaks:
          🕓 12:00 pm - 12:30 pm
          ⏸️  30 minutes
          💰 false

      Leave taken: 8 hours and 0 minutes
      📅 Wednesday, 25 Dec 2024
      🚧 Approved
      🌴 Holiday Leave
      ℹ️  Christmas Day

      You've worked 8 hours and 0 minutes this week
      You've taken 8 hours and 0 minutes of leave this week

      OUTPUT

      context.stdout.to_s.should eq(expected)
    end
  end

  it "Display assumes expected finish date for clock out if forgotten" do
    WebMock
      .stub(:get, endpoint(Regex.new("/shifts")))
      .to_return(
        status: 200,
        body: [
          build_shift(
            id: 1,
            start: Time.local(2024, 12, 23, 8, 30),
            finish: nil,
            break_start: Time.local(2024, 12, 23, 12),
            break_finish: Time.local(2024, 12, 23, 12, 30)
          ),
          build_shift(
            id: 2,
            start: Time.local(2024, 12, 24, 8, 30),
            finish: nil,
            break_start: Time.local(2024, 12, 24, 12),
            break_finish: Time.local(2024, 12, 24, 12, 30)
          ),
        ].to_json,
      )

    travel_to(Time.local(2024, 12, 24, 14))

    context = run(["time_worked", "week", "--display"])

    expected = <<-OUTPUT.gsub("<space>", " ")
    ⚠️ Warning: Missing finish time for Monday, assuming regular hours finish time
    Time worked: 8 hours and 0 minutes
    📅 Monday, 23 Dec 2024
    🕓 8:30 am - 5:00 pm
    🚧 Pending
    ☕️ Breaks:
        🕓 12:00 pm - 12:30 pm
        ⏸️  30 minutes
        💰 false

    Worked so far: 5 hours and 0 minutes
    📅 Tuesday, 24 Dec 2024
    🕓 8:30 am -<space>
    🚧 Pending
    ☕️ Breaks:
        🕓 12:00 pm - 12:30 pm
        ⏸️  30 minutes
        💰 false

    Time left today: 3 hours and 0 minutes
    You can clock out at: 5:00 pm

    You've worked 13 hours and 0 minutes this week

    OUTPUT

    context.stdout.to_s.should eq(expected)
  end

  it "Shows overtime if previous day filled and past expected finish" do
    WebMock
      .stub(:get, endpoint(Regex.new("/shifts")))
      .to_return(
        status: 200,
        body: [
          build_shift(
            id: 1,
            start: Time.local(2024, 12, 23, 8, 30),
            finish: nil,
            break_start: Time.local(2024, 12, 23, 12),
            break_finish: Time.local(2024, 12, 23, 12, 30)
          ),
          build_shift(
            id: 2,
            start: Time.local(2024, 12, 24, 8, 30),
            finish: nil,
            break_start: Time.local(2024, 12, 24, 12),
            break_finish: Time.local(2024, 12, 24, 12, 30)
          ),
        ].to_json,
      )

    travel_to(Time.local(2024, 12, 24, 19))

    context = run(["time_worked", "week", "--display"])

    expected = <<-OUTPUT.gsub("<space>", " ")
    ⚠️ Warning: Missing finish time for Monday, assuming regular hours finish time
    Time worked: 8 hours and 0 minutes
    📅 Monday, 23 Dec 2024
    🕓 8:30 am - 5:00 pm
    🚧 Pending
    ☕️ Breaks:
        🕓 12:00 pm - 12:30 pm
        ⏸️  30 minutes
        💰 false

    Worked so far: 10 hours and 0 minutes
    📅 Tuesday, 24 Dec 2024
    🕓 8:30 am -<space>
    🚧 Pending
    ☕️ Breaks:
        🕓 12:00 pm - 12:30 pm
        ⏸️  30 minutes
        💰 false

    Overtime this week: 2 hours and 0 minutes
    Overtime since: 5:00 pm

    You've worked 18 hours and 0 minutes this week

    OUTPUT

    context.stdout.to_s.should eq(expected)
  end

  it "Doesn't show time left or overtime if next day with assumed regular hours without breaks" do
    WebMock
      .stub(:get, endpoint(Regex.new("/shifts")))
      .to_return(
        status: 200,
        body: [
          build_shift(
            id: 1,
            start: Time.local(2024, 12, 23, 8, 30),
            finish: nil,
            break_start: nil,
            break_finish: nil
          ),
          build_shift(
            id: 2,
            start: Time.local(2024, 12, 24, 8, 30),
            finish: nil,
            break_start: nil,
            break_finish: nil
          ),
        ].to_json,
      )

    travel_to(Time.local(2024, 12, 25, 1))

    context = run(["time_worked", "week", "--display"])

    expected = <<-OUTPUT.gsub("<space>", " ")
    ⚠️ Warning: Missing finish time for Monday, assuming regular hours finish time
    Time worked: 8 hours and 0 minutes
    📅 Monday, 23 Dec 2024
    🕓 8:30 am - 5:00 pm
    🚧 Pending
    ☕️ 30 minutes

    ⚠️ Warning: Missing finish time for Tuesday, assuming regular hours finish time
    Time worked: 8 hours and 0 minutes
    📅 Tuesday, 24 Dec 2024
    🕓 8:30 am - 5:00 pm
    🚧 Pending
    ☕️ 30 minutes

    You've worked 16 hours and 0 minutes this week

    OUTPUT

    context.stdout.to_s.should eq(expected)
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
      if break_start || break_finish
        {
          id:                               1,
          selected_automatic_break_rule_id: nil,
          shift_id:                         id,
          start:                            break_start.try(&.to_unix),
          finish:                           break_finish.try(&.to_unix),
          length:                           30,
          paid:                             false,
          updated_at:                       1735259689,
        }
      end,
    ].compact,
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

private def build_shift_without_breaks(id, start, finish)
  {
    id:               id,
    timesheet_id:     1,
    user_id:          1,
    date:             TandaCLI::Utils::Time.iso_date(start),
    start:            start.try(&.to_unix),
    break_start:      nil,
    break_finish:     nil,
    break_length:     nil,
    breaks:           [] of Hash(String, String),
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

private def build_leave_shift(id, date, leave_request_id)
  {
    id:               id,
    timesheet_id:     1,
    user_id:          1,
    date:             TandaCLI::Utils::Time.iso_date(date),
    start:            nil,
    break_start:      nil,
    break_finish:     nil,
    break_length:     nil,
    breaks:           [] of Hash(String, String),
    finish:           nil,
    department_id:    1,
    sub_cost_centre:  nil,
    tag:              nil,
    tag_id:           nil,
    status:           "PENDING",
    metadata:         nil,
    leave_request_id: leave_request_id,
    allowances:       [] of Hash(String, String),
    approved_by:      nil,
    approved_at:      nil,
    notes:            [] of Hash(String, String),
    updated_at:       1735259689,
    record_id:        1,
  }
end

private def build_leave_request(
  id,
  shift_id,
  date,
  hours,
  leave_type = "Annual Leave",
  status = "approved",
  reason = nil,
)
  {
    id:              id,
    user_id:         1,
    leave_type:      leave_type,
    status:          status,
    reason:          reason,
    daily_breakdown: [
      {
        id:          shift_id.to_s,
        date:        date,
        start_time:  nil,
        finish_time: nil,
        hours:       hours,
      },
    ],
  }
end
