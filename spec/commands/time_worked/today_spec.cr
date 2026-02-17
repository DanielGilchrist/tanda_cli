require "./spec_helper"

describe TandaCLI::Commands::TimeWorked::Today do
  it "Displays time worked for today" do
    TimeWorkedSpecHelper.stub_shifts([
      ShiftBuilder.build_shift(
        id: 1,
        start: Time.local(2024, 12, 23, 8, 30),
        finish: Time.local(2024, 12, 23, 17),
        break_start: Time.local(2024, 12, 23, 12),
        break_finish: Time.local(2024, 12, 23, 12, 30),
        break_length: 30,
      ),
    ].to_json)

    travel_to(Time.local(2024, 12, 24)) do
      context = run(["time_worked", "today"])
      context.stdout.to_s.should eq("You've worked 8 hours and 0 minutes today\n")
    end
  end

  it "Displays time worked for today displaying shifts when --display flag is passed" do
    TimeWorkedSpecHelper.stub_shifts([
      ShiftBuilder.build_shift(
        id: 1,
        start: Time.local(2024, 12, 23, 8, 30),
        finish: Time.local(2024, 12, 23, 17),
        break_start: Time.local(2024, 12, 23, 12),
        break_finish: Time.local(2024, 12, 23, 12, 30),
        break_length: 30,
      ),
    ].to_json)

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
