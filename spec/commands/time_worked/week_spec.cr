require "./spec_helper"

describe TandaCLI::Commands::TimeWorked::Week do
  it "Displays time worked for the week" do
    TimeWorkedSpecHelper.stub_shifts([
      ShiftBuilder.build_shift(
        id: 1,
        start: Time.local(2024, 12, 23, 8, 30),
        finish: Time.local(2024, 12, 23, 17),
        break_start: Time.local(2024, 12, 23, 12),
        break_finish: Time.local(2024, 12, 23, 12, 30),
        break_length: 30,
      ),
      ShiftBuilder.build_shift(
        id: 2,
        start: Time.local(2024, 12, 24, 8, 30),
        finish: Time.local(2024, 12, 24, 17),
        break_start: Time.local(2024, 12, 24, 12),
        break_finish: Time.local(2024, 12, 24, 12, 30),
        break_length: 30,
      ),
    ].to_json)

    travel_to(Time.local(2024, 12, 24)) do
      context = run(["time_worked", "week"])
      context.stdout.to_s.should eq("⏱️  Worked: 16 hours and 0 minutes\n")
    end
  end

  it "Displays time worked for week displaying shifts when --display flag is passed" do
    TimeWorkedSpecHelper.stub_shifts([
      ShiftBuilder.build_shift(
        id: 1,
        start: Time.local(2024, 12, 23, 8, 30),
        finish: Time.local(2024, 12, 23, 17),
        break_start: Time.local(2024, 12, 23, 12),
        break_finish: Time.local(2024, 12, 23, 12, 30),
        break_length: 30,
      ),
      ShiftBuilder.build_shift(
        id: 2,
        start: Time.local(2024, 12, 24, 8, 30),
        finish: nil,
        break_start: Time.local(2024, 12, 24, 12),
        break_finish: Time.local(2024, 12, 24, 12, 30),
        break_length: 30,
      ),
    ].to_json)

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

      ⏳ Time left: 3 hours and 0 minutes
      🏁 Clock out at: 5:00 pm

      ⏱️  Worked: 13 hours and 0 minutes

      OUTPUT

      context.stdout.to_s.should eq(expected)
    end
  end

  it "Does not assume a scheduled break for a second shift on the same day when breaks have already been taken" do
    TimeWorkedSpecHelper.stub_shifts([
      ShiftBuilder.build_shift(
        id: 1,
        start: Time.local(2024, 12, 23, 8, 41),
        finish: Time.local(2024, 12, 23, 15, 1),
        break_start: Time.local(2024, 12, 23, 12, 4),
        break_finish: Time.local(2024, 12, 23, 12, 51),
        break_length: 30,
      ),
      ShiftBuilder.build_shift(
        id: 2,
        start: Time.local(2024, 12, 23, 16, 27),
        finish: nil,
      ),
    ].to_json)

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

      ⏳ Time left: 1 hours and 17 minutes
      🏁 Clock out at: 6:37 pm

      ⏱️  Worked: 6 hours and 43 minutes

      OUTPUT

      context.stdout.to_s.should eq(expected)
    end
  end

  it "Displays leave taken for the week" do
    leave_request_id = 100

    TimeWorkedSpecHelper.stub_shifts([
      ShiftBuilder.build_shift(
        id: 1,
        start: Time.local(2024, 12, 23, 8, 30),
        finish: Time.local(2024, 12, 23, 17),
        break_start: Time.local(2024, 12, 23, 12),
        break_finish: Time.local(2024, 12, 23, 12, 30),
        break_length: 30,
      ),
      ShiftBuilder.build_shift(
        id: 3,
        date: Time.local(2024, 12, 25),
        leave_request_id: leave_request_id,
      ),
    ].to_json)

    TimeWorkedSpecHelper.stub_leave_requests([
      ShiftBuilder.build_leave_request(
        id: leave_request_id,
        shift_id: 3,
        date: "2024-12-25",
        hours: 8.0,
      ),
    ].to_json)

    travel_to(Time.local(2024, 12, 25)) do
      context = run(["time_worked", "week"])
      expected = <<-OUTPUT
      ⏱️  Worked: 8 hours and 0 minutes
      🌴 Leave: 8 hours and 0 minutes

      OUTPUT

      context.stdout.to_s.should eq(expected)
    end
  end

  it "Displays leave taken with --display flag" do
    leave_request_id = 100

    TimeWorkedSpecHelper.stub_shifts([
      ShiftBuilder.build_shift(
        id: 1,
        start: Time.local(2024, 12, 23, 8, 30),
        finish: Time.local(2024, 12, 23, 17),
        break_start: Time.local(2024, 12, 23, 12),
        break_finish: Time.local(2024, 12, 23, 12, 30),
        break_length: 30,
      ),
      ShiftBuilder.build_shift(
        id: 3,
        date: Time.local(2024, 12, 25),
        leave_request_id: leave_request_id,
      ),
    ].to_json)

    TimeWorkedSpecHelper.stub_leave_requests([
      ShiftBuilder.build_leave_request(
        id: leave_request_id,
        shift_id: 3,
        date: "2024-12-25",
        hours: 8.0,
        leave_type: "Holiday Leave",
        status: "approved",
        reason: "Christmas Day",
      ),
    ].to_json)

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

      ⏱️  Worked: 8 hours and 0 minutes
      🌴 Leave: 8 hours and 0 minutes

      OUTPUT

      context.stdout.to_s.should eq(expected)
    end
  end

  it "Assumes expected finish time for clock out if forgotten on a previous day" do
    TimeWorkedSpecHelper.stub_shifts([
      ShiftBuilder.build_shift(
        id: 1,
        start: Time.local(2024, 12, 23, 8, 30),
        finish: nil,
        break_start: Time.local(2024, 12, 23, 12),
        break_finish: Time.local(2024, 12, 23, 12, 30),
        break_length: 30,
      ),
      ShiftBuilder.build_shift(
        id: 2,
        start: Time.local(2024, 12, 24, 8, 30),
        finish: nil,
        break_start: Time.local(2024, 12, 24, 12),
        break_finish: Time.local(2024, 12, 24, 12, 30),
        break_length: 30,
      ),
    ].to_json)

    travel_to(Time.local(2024, 12, 24, 14)) do
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

      ⏳ Time left: 3 hours and 0 minutes
      🏁 Clock out at: 5:00 pm

      ⏱️  Worked: 13 hours and 0 minutes

      OUTPUT

      context.stdout.to_s.should eq(expected)
    end
  end

  it "Shows overtime if previous day filled and past expected finish" do
    TimeWorkedSpecHelper.stub_shifts([
      ShiftBuilder.build_shift(
        id: 1,
        start: Time.local(2024, 12, 23, 8, 30),
        finish: nil,
        break_start: Time.local(2024, 12, 23, 12),
        break_finish: Time.local(2024, 12, 23, 12, 30),
        break_length: 30,
      ),
      ShiftBuilder.build_shift(
        id: 2,
        start: Time.local(2024, 12, 24, 8, 30),
        finish: nil,
        break_start: Time.local(2024, 12, 24, 12),
        break_finish: Time.local(2024, 12, 24, 12, 30),
        break_length: 30,
      ),
    ].to_json)

    travel_to(Time.local(2024, 12, 24, 19)) do
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

      🔥 Overtime: 2 hours and 0 minutes
      ⏰ Since: 5:00 pm

      ⏱️  Worked: 18 hours and 0 minutes

      OUTPUT

      context.stdout.to_s.should eq(expected)
    end
  end

  it "Assumes regular hours for next day with no breaks" do
    TimeWorkedSpecHelper.stub_shifts([
      ShiftBuilder.build_shift(
        id: 1,
        start: Time.local(2024, 12, 23, 8, 30),
        finish: nil,
      ),
      ShiftBuilder.build_shift(
        id: 2,
        start: Time.local(2024, 12, 24, 8, 30),
        finish: nil,
      ),
    ].to_json)

    travel_to(Time.local(2024, 12, 25, 1)) do
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

      ⏱️  Worked: 16 hours and 0 minutes

      OUTPUT

      context.stdout.to_s.should eq(expected)
    end
  end
end
