require "../../spec_helper"

describe TandaCLI::Commands::ClockIn::Manual do
  it "Handles clocked out state asking for a time to clock in with" do
    stub_shifts

    travel_to(Time.local(2024, 12, 28, 9))

    stdin = build_stdin(
      "9:00am",
      "y"
    )
    context = run(stdin)

    output = context.stdout.to_s
    output.should contain("You are currently clocked out, what do you want to set as the clock in time?\n")
    output.should contain("Is this correct?\n")
    output.should contain("Success: Set clock in time to 2024-12-28 09:00:00 +00:00\n")
  end

  it "Handles blank time input" do
    stub_shifts

    stdin = build_stdin("  ")
    context = run(stdin)

    output = context.stdout.to_s
    output.should contain("You are currently clocked out, what do you want to set as the clock in time?\n")
    output.should contain("Error: Input can't be blank!")
  end

  it "Handles invalid time input" do
    stub_shifts

    time_string = "invalid time"
    stdin = build_stdin(time_string)
    context = run(stdin)

    output = context.stdout.to_s
    output.should contain("You are currently clocked out, what do you want to set as the clock in time?\n")
    output.should contain("Error: \"#{time_string}\" is not a valid time!\n")
  end
end

private def run(stdin)
  Command.run(["clockin", "manual"], stdin: stdin)
end

private def stub_shifts(shifts = Array(NamedTuple()).new)
  WebMock
    .stub(:get, endpoint(Regex.new("/shifts")))
    .to_return(
      status: 200,
      body: shifts.to_json,
    )
end
