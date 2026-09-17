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

  it "clocks in with a short am meridiem in --at" do
    travel_to(Time.local(2026, 2, 17, 10, 0)) do
      ClockInSpecHelper.stub_shifts(ClockInSpecHelper.no_shifts)
      ClockInSpecHelper.stub_clockin_success

      context = run(["clockin", "start", "--at", "8:45a"])

      context.stdout.to_s.should eq("Success: Clock in recorded at 8:45 am! (1 | Test Organisation)\n")
      context.stderr.to_s.should be_empty
    end
  end

  it "clocks in with a short pm meridiem in --at" do
    travel_to(Time.local(2026, 2, 17, 21, 0)) do
      ClockInSpecHelper.stub_shifts(ClockInSpecHelper.no_shifts)
      ClockInSpecHelper.stub_clockin_success

      context = run(["clockin", "start", "--at", "8p"])

      context.stdout.to_s.should eq("Success: Clock in recorded at 8:00 pm! (1 | Test Organisation)\n")
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

    context.stderr.to_s.should contain("\"potato\" isn't a valid time of day for \"--at\"")
    context.stderr.to_s.should contain(%(try "8:45", "5:30pm" or "17:30"))
    context.stdout.to_s.should be_empty
  end

  it "errors when --at has an hour outside 1-12 with a meridiem" do
    context = run(["clockin", "start", "--at", "13p"])

    context.stderr.to_s.should contain("\"13p\" isn't a valid time of day for \"--at\"")
    context.stdout.to_s.should be_empty
  end

  it "errors when --date is given without --at" do
    context = run(["clockin", "start", "--date", "yesterday"])

    context.stderr.to_s.should eq("Error: The --date option can only be used with --at\n")
    context.stdout.to_s.should be_empty
  end

  it "clocks in on a day of the week given to --date" do
    travel_to(Time.local(2026, 2, 18, 10, 0)) do
      ClockInSpecHelper.stub_shifts(ClockInSpecHelper.no_shifts)
      ClockInSpecHelper.stub_clockin_success

      context = run(["clockin", "start", "--at", "8:45am", "--date", "tuesday"])

      context.stdout.to_s.should eq("Success: Clock in recorded at 8:45 am (Tuesday, 17 Feb 2026)! (1 | Test Organisation)\n")
      context.stderr.to_s.should be_empty
    end
  end

  it "clocks in on an abbreviated day of the week given to --date" do
    travel_to(Time.local(2026, 2, 18, 10, 0)) do
      ClockInSpecHelper.stub_shifts(ClockInSpecHelper.no_shifts)
      ClockInSpecHelper.stub_clockin_success

      context = run(["clockin", "start", "--at", "8:45am", "--date", "TUE"])

      context.stdout.to_s.should eq("Success: Clock in recorded at 8:45 am (Tuesday, 17 Feb 2026)! (1 | Test Organisation)\n")
      context.stderr.to_s.should be_empty
    end
  end

  it "resolves a day of the week against the configured start of the week" do
    travel_to(Time.local(2026, 2, 18, 10, 0)) do
      ClockInSpecHelper.stub_shifts(ClockInSpecHelper.no_shifts)
      ClockInSpecHelper.stub_clockin_success

      context = run(["clockin", "start", "--at", "8:45am", "--date", "sun"])

      context.stdout.to_s.should eq("Success: Clock in recorded at 8:45 am (Sunday, 15 Feb 2026)! (1 | Test Organisation)\n")
      context.stderr.to_s.should be_empty
    end
  end

  it "resolves a day of the week from the previous week when the start of the week moves" do
    travel_to(Time.local(2026, 2, 18, 10, 0)) do
      ClockInSpecHelper.stub_shifts(ClockInSpecHelper.no_shifts)
      ClockInSpecHelper.stub_clockin_success

      context = run(["clockin", "start", "--at", "8:45am", "--date", "monday"], config_fixture: :monday_start_of_week)

      context.stdout.to_s.should eq("Success: Clock in recorded at 8:45 am (Monday, 16 Feb 2026)! (1 | Test Organisation)\n")
      context.stderr.to_s.should be_empty
    end
  end

  it "errors when a day of the week hasn't happened yet this week" do
    travel_to(Time.local(2026, 2, 18, 10, 0)) do
      context = run(["clockin", "start", "--at", "8:45am", "--date", "friday"])

      context.stderr.to_s.should contain("Friday, 20 Feb 2026 | 8:45 am hasn't happened yet.")
      context.stdout.to_s.should be_empty
    end
  end

  it "errors when --date is too short to name a day" do
    context = run(["clockin", "start", "--at", "8:45am", "--date", "tu"])

    context.stderr.to_s.should contain(%("tu" isn't a valid day for "--date"))
    context.stderr.to_s.should contain(%(Try a day name like "wednesday" or "wed", "today", "yesterday" or YYYY-MM-DD))
    context.stdout.to_s.should be_empty
  end
end
