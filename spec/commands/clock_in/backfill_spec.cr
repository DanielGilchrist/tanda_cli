require "./spec_helper"

describe TandaCLI::Commands::ClockIn::Backfill do
  it "backfills a full day" do
    travel_to(Time.local(2026, 2, 17, 18, 0)) do
      ClockInSpecHelper.stub_shifts(ClockInSpecHelper.no_shifts)
      ClockInSpecHelper.stub_clockin_success

      stdin = build_stdin("8:45", "12:00", "12:30", "", "17:30", "")
      context = run(["clockin", "backfill"], stdin: stdin)

      output = context.stdout.to_s
      output.should contain("📅 Tuesday, 17 Feb 2026")
      output.should contain("No clock ins recorded.")
      output.should contain("Clock in: 8:45 am")
      output.should contain("Break start: 12:00 pm")
      output.should contain("Break finish: 12:30 pm")
      output.should contain("Clock out: 5:30 pm")
      output.should contain("Success: Backfilled 4 clock ins for Tuesday, 17 Feb 2026")
      context.stderr.to_s.should be_empty
    end
  end

  it "resumes from an open break" do
    travel_to(ClockInSpecHelper::BREAK_START + 2.hours) do
      ClockInSpecHelper.stub_shifts(ClockInSpecHelper.on_break_shift)
      ClockInSpecHelper.stub_clockin_success

      stdin = build_stdin("1:25am", "", "2:30am", "")
      context = run(["clockin", "backfill"], stdin: stdin)

      output = context.stdout.to_s
      output.should contain("You clocked in at 12:54 am.")
      output.should contain("Your break started at 12:55 am.")
      output.should contain("Break finish: 1:25 am")
      output.should contain("Clock out: 2:30 am")
      output.should contain("Success: Backfilled 2 clock ins for Tuesday, 17 Feb 2026")
      context.stderr.to_s.should be_empty
    end
  end

  it "does nothing when the day is already complete" do
    travel_to(ClockInSpecHelper::SHIFT_FINISH + 1.hour) do
      ClockInSpecHelper.stub_shifts(ClockInSpecHelper.clocked_out_shift)

      context = run(["clockin", "backfill"])

      context.stdout.to_s.should contain("Nothing to backfill — this day is already complete.")
      context.stderr.to_s.should be_empty
    end
  end

  it "re-prompts when a time is out of order" do
    travel_to(Time.local(2026, 2, 17, 18, 0)) do
      ClockInSpecHelper.stub_shifts(ClockInSpecHelper.no_shifts)
      ClockInSpecHelper.stub_clockin_success

      stdin = build_stdin("9:00", "8:30", "", "", "")
      context = run(["clockin", "backfill"], stdin: stdin)

      context.stderr.to_s.should contain(
        "Error: Clock in time is out of order!\n" \
        "       8:30 am must be after 9:00 am.\n"
      )
      context.stdout.to_s.should contain("Success: Backfilled 1 clock in for Tuesday, 17 Feb 2026")
    end
  end

  it "submits nothing when declined" do
    travel_to(Time.local(2026, 2, 17, 18, 0)) do
      ClockInSpecHelper.stub_shifts(ClockInSpecHelper.no_shifts)

      stdin = build_stdin("8:45", "", "", "n")
      context = run(["clockin", "backfill"], stdin: stdin)

      context.stdout.to_s.should contain("Cancelled — nothing submitted.")
      context.stderr.to_s.should be_empty
    end
  end

  it "errors for a future date" do
    travel_to(Time.local(2026, 2, 17, 18, 0)) do
      context = run(["clockin", "backfill", "--date", "2026-02-20"])

      context.stderr.to_s.should eq("Error: You can't backfill a future date\n")
    end
  end
end
