require "./spec_helper"

describe TandaCLI::Commands::ClockIn::Start do
  it "clocks in successfully when clocked out" do
    ClockInSpecHelper.stub_shifts(ClockInSpecHelper.no_shifts)
    ClockInSpecHelper.stub_clockin_success

    context = run(["clockin", "start"])

    context.stdout.to_s.should eq("Success: You are now clocked in! (1 | Test Organisation)\n")
    context.stderr.to_s.should be_empty
  end

  it "errors when already clocked in" do
    ClockInSpecHelper.stub_shifts(ClockInSpecHelper.clocked_in_shift)

    context = run(["clockin", "start"])

    context.stderr.to_s.should eq("Error: You are already clocked in!\n")
    context.stdout.to_s.should be_empty
  end

  it "errors when on break" do
    ClockInSpecHelper.stub_shifts(ClockInSpecHelper.on_break_shift)

    context = run(["clockin", "start"])

    context.stderr.to_s.should eq("Error: You can't clock in when a break has started!\n")
    context.stdout.to_s.should be_empty
  end

  it "clocks in at a backdated time with --at" do
    travel_to(Time.local(2026, 2, 17, 10, 0)) do
      ClockInSpecHelper.stub_shifts(ClockInSpecHelper.no_shifts)
      ClockInSpecHelper.stub_clockin_success

      context = run(["clockin", "start", "--at", "8:45"])

      context.stdout.to_s.should eq("Success: Clock in recorded at 8:45 am! (1 | Test Organisation)\n")
      context.stderr.to_s.should be_empty
    end
  end

  it "clocks in on a previous day with --at and --date" do
    travel_to(Time.local(2026, 2, 18, 10, 0)) do
      ClockInSpecHelper.stub_shifts(ClockInSpecHelper.no_shifts)
      ClockInSpecHelper.stub_clockin_success

      context = run(["clockin", "start", "--at", "8:45am", "--date", "yesterday"])

      context.stdout.to_s.should eq("Success: Clock in recorded at 8:45 am (Tuesday, 17 Feb 2026)! (1 | Test Organisation)\n")
      context.stderr.to_s.should be_empty
    end
  end

  it "errors when --at is in the future" do
    travel_to(Time.local(2026, 2, 17, 10, 0)) do
      context = run(["clockin", "start", "--at", "11:00"])

      context.stderr.to_s.should eq(
        "Error: Clock in time is in the future!\n" \
        "       Tuesday, 17 Feb 2026 | 11:00 am hasn't happened yet.\n"
      )
      context.stdout.to_s.should be_empty
    end
  end

  it "errors when --at can't be parsed" do
    context = run(["clockin", "start", "--at", "potato"])

    context.stderr.to_s.should eq(
      "Error: Unable to parse time!\n" \
      "       \"potato\" doesn't look like a time of day (try \"8:45\", \"5:30pm\" or \"17:30\").\n"
    )
    context.stdout.to_s.should be_empty
  end

  it "errors when --date is given without --at" do
    context = run(["clockin", "start", "--date", "yesterday"])

    context.stderr.to_s.should eq("Error: The --date option can only be used with --at\n")
    context.stdout.to_s.should be_empty
  end
end
