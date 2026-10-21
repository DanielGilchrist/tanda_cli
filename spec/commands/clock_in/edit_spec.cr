require "./spec_helper"

private def completed_shift_with_break : String
  [
    ShiftBuilder.build_shift(
      id: 1,
      start: ClockInSpecHelper::SHIFT_START,
      finish: ClockInSpecHelper::SHIFT_FINISH,
      break_start: ClockInSpecHelper::BREAK_START,
      break_finish: ClockInSpecHelper::BREAK_FINISH,
      break_length: 30,
    ),
  ].to_json
end

describe TandaCLI::Commands::ClockIn::Edit do
  it "updates the start and finish of a previous day's shift" do
    travel_to(Time.local(2026, 2, 18, 10, 0)) do
      ClockInSpecHelper.stub_shifts(completed_shift_with_break)
      ClockInSpecHelper.stub_shift_update(1, {
        start:  Time.local(2026, 2, 17, 0, 50).to_unix,
        finish: Time.local(2026, 2, 17, 9, 0).to_unix,
      }.to_json)

      stdin = build_stdin("1", "12:50am", "3", "9:00am", "", "")
      context = run(["clockin", "edit", "--date", "yesterday"], stdin: stdin)

      context.stdout.to_s.should eq(
        "📅 Tuesday, 17 Feb 2026\n" \
        "\n" \
        "  1  Start    12:54 am\n" \
        "  2  Break 1  12:55 am - 1:25 am\n" \
        "  3  Finish   8:54 am\n" \
        "\n" \
        "Edit which? 1-3, b to add a break, Enter when done › " \
        "  Type a time like 8:30am. Enter keeps it, none clears it.\n" \
        "  Start  12:54 am › " \
        "\n" \
        "  1  Start    12:50 am  was 12:54 am\n" \
        "  2  Break 1  12:55 am - 1:25 am\n" \
        "  3  Finish   8:54 am\n" \
        "\n" \
        "Edit which? 1-3, b to add a break, Enter when done › " \
        "  Finish  8:54 am › " \
        "\n" \
        "  1  Start    12:50 am  was 12:54 am\n" \
        "  2  Break 1  12:55 am - 1:25 am\n" \
        "  3  Finish   9:00 am  was 8:54 am\n" \
        "\n" \
        "Edit which? 1-3, b to add a break, Enter when done › " \
        "Submit? (Y/n) " \
        "Success: Updated your shift for Tuesday, 17 Feb 2026\n"
      )
      context.stderr.to_s.should be_empty
    end
  end

  it "changes an existing break and adds another" do
    travel_to(Time.local(2026, 2, 18, 10, 0)) do
      ClockInSpecHelper.stub_shifts(completed_shift_with_break)
      ClockInSpecHelper.stub_break_update(1, 1, {
        start:  Time.local(2026, 2, 17, 1, 0).to_unix,
        finish: Time.local(2026, 2, 17, 1, 30).to_unix,
      }.to_json)
      ClockInSpecHelper.stub_break_create(1, {
        start:  Time.local(2026, 2, 17, 3, 0).to_unix,
        finish: Time.local(2026, 2, 17, 3, 15).to_unix,
      }.to_json)

      stdin = build_stdin("2", "1am", "1:30am", "b", "3am", "3:15am", "", "")
      context = run(["clockin", "edit", "--date", "yesterday"], stdin: stdin)

      output = context.stdout.to_s
      output.should contain("  New break finish  open › ")
      output.should contain("  Break 1  1:00 am - 1:30 am  was 12:55 am - 1:25 am\n")
      output.should contain("  Break 2  3:00 am - 3:15 am  new\n")
      output.should contain("Success: Updated your shift for Tuesday, 17 Feb 2026")
      context.stderr.to_s.should be_empty
    end
  end

  it "removes a break" do
    travel_to(Time.local(2026, 2, 18, 10, 0)) do
      ClockInSpecHelper.stub_shifts(completed_shift_with_break)
      ClockInSpecHelper.stub_break_update(1, 1, %({"start":null,"finish":null,"length":0}))

      stdin = build_stdin("2", "none", "", "")
      context = run(["clockin", "edit", "--date", "yesterday"], stdin: stdin)

      output = context.stdout.to_s
      output.should_not contain("Break 1 finish")
      output.should contain("     Removed  12:55 am - 1:25 am\n")
      output.should contain("Success: Updated your shift for Tuesday, 17 Feb 2026")
      context.stderr.to_s.should be_empty
    end
  end

  it "clears the start and finish" do
    travel_to(Time.local(2026, 2, 18, 10, 0)) do
      ClockInSpecHelper.stub_shifts(completed_shift_with_break)
      ClockInSpecHelper.stub_shift_update(1, %({"start":null,"finish":null}))

      stdin = build_stdin("1", "none", "3", "NONE", "", "")
      context = run(["clockin", "edit", "--date", "yesterday"], stdin: stdin)

      output = context.stdout.to_s
      output.should contain("  1  Start    none  was 12:54 am\n")
      output.should contain("  3  Finish   none  was 8:54 am\n")
      output.should contain("Success: Updated your shift for Tuesday, 17 Feb 2026")
      context.stderr.to_s.should be_empty
    end
  end

  it "clears a break's finish" do
    travel_to(Time.local(2026, 2, 18, 10, 0)) do
      ClockInSpecHelper.stub_shifts(completed_shift_with_break)
      ClockInSpecHelper.stub_break_update(1, 1, %({"finish":null}))

      stdin = build_stdin("2", "", "none", "", "")
      context = run(["clockin", "edit", "--date", "yesterday"], stdin: stdin)

      output = context.stdout.to_s
      output.should contain("  2  Break 1  12:55 am - (open)  was 12:55 am - 1:25 am\n")
      output.should contain("Success: Updated your shift for Tuesday, 17 Feb 2026")
      context.stderr.to_s.should be_empty
    end
  end

  it "rejects a break outside the shift" do
    travel_to(Time.local(2026, 2, 18, 10, 0)) do
      ClockInSpecHelper.stub_shifts(completed_shift_with_break)

      stdin = build_stdin("b", "9am", "9:30am", "")
      context = run(["clockin", "edit", "--date", "yesterday"], stdin: stdin)

      context.stderr.to_s.should contain(
        "Error: Clock in time is out of order!\n" \
        "       8:54 am must be after 9:30 am.\n"
      )
      context.stdout.to_s.should_not contain("Success")
    end
  end

  it "re-prompts when a time can't be parsed" do
    travel_to(Time.local(2026, 2, 18, 10, 0)) do
      ClockInSpecHelper.stub_shifts(completed_shift_with_break)
      ClockInSpecHelper.stub_shift_update(1, {start: Time.local(2026, 2, 17, 0, 50).to_unix}.to_json)

      stdin = build_stdin("1", "nope", "12:50am", "", "")
      context = run(["clockin", "edit", "--date", "yesterday"], stdin: stdin)

      context.stderr.to_s.should_not be_empty
      context.stdout.to_s.should contain("Success: Updated your shift for Tuesday, 17 Feb 2026")
    end
  end

  it "picks between multiple shifts" do
    travel_to(Time.local(2026, 2, 18, 10, 0)) do
      ClockInSpecHelper.stub_shifts([
        ShiftBuilder.build_shift(id: 1, start: ClockInSpecHelper::SHIFT_START, finish: Time.local(2026, 2, 17, 4, 0)),
        ShiftBuilder.build_shift(id: 2, start: Time.local(2026, 2, 17, 5, 0), finish: ClockInSpecHelper::SHIFT_FINISH),
      ].to_json)
      ClockInSpecHelper.stub_shift_update(2, {finish: Time.local(2026, 2, 17, 9, 0).to_unix}.to_json)

      stdin = build_stdin("0", "2", "2", "9am", "", "")
      context = run(["clockin", "edit", "--date", "yesterday"], stdin: stdin)

      output = context.stdout.to_s
      output.should contain("  1  12:54 am - 4:00 am\n")
      output.should contain("  2  5:00 am - 8:54 am\n")
      output.should contain("Which shift? 1-2 › ")
      output.should contain("  2  Finish  9:00 am  was 8:54 am\n")
      context.stderr.to_s.should contain("\"0\" isn't a number from 1 to 2.")
    end
  end

  it "submits nothing when declined" do
    travel_to(Time.local(2026, 2, 18, 10, 0)) do
      ClockInSpecHelper.stub_shifts(completed_shift_with_break)

      stdin = build_stdin("1", "12:50am", "", "n")
      context = run(["clockin", "edit", "--date", "yesterday"], stdin: stdin)

      context.stdout.to_s.should contain("Cancelled. Nothing submitted.")
      context.stderr.to_s.should be_empty
    end
  end

  it "does nothing when nothing changes" do
    travel_to(Time.local(2026, 2, 18, 10, 0)) do
      ClockInSpecHelper.stub_shifts(completed_shift_with_break)

      stdin = build_stdin("")
      context = run(["clockin", "edit", "--date", "yesterday"], stdin: stdin)

      context.stdout.to_s.should eq(
        "📅 Tuesday, 17 Feb 2026\n" \
        "\n" \
        "  1  Start    12:54 am\n" \
        "  2  Break 1  12:55 am - 1:25 am\n" \
        "  3  Finish   8:54 am\n" \
        "\n" \
        "Edit which? 1-3, b to add a break, Enter when done › " \
        "No changes made.\n"
      )
      context.stderr.to_s.should be_empty
    end
  end

  it "re-prompts when the choice isn't on the list" do
    travel_to(Time.local(2026, 2, 18, 10, 0)) do
      ClockInSpecHelper.stub_shifts(completed_shift_with_break)

      stdin = build_stdin("4", "")
      context = run(["clockin", "edit", "--date", "yesterday"], stdin: stdin)

      context.stderr.to_s.should contain("\"4\" isn't a number from 1 to 3 or b.")
      context.stdout.to_s.should contain("No changes made.")
    end
  end

  it "points to backfill when there are no clock ins" do
    travel_to(Time.local(2026, 2, 18, 10, 0)) do
      ClockInSpecHelper.stub_shifts(ClockInSpecHelper.no_shifts)

      context = run(["clockin", "edit", "--date", "yesterday"])

      context.stdout.to_s.should contain("No clock ins recorded for Tuesday, 17 Feb 2026. Use `clockin backfill` to add them.")
    end
  end

  it "edits a shift that's still going" do
    travel_to(ClockInSpecHelper::SHIFT_START + 2.hours) do
      ClockInSpecHelper.stub_shifts(ClockInSpecHelper.on_break_shift)
      ClockInSpecHelper.stub_shift_update(1, {start: Time.local(2026, 2, 17, 0, 50).to_unix}.to_json)

      stdin = build_stdin("2", "", "", "3", "", "1", "12:50am", "", "")
      context = run(["clockin", "edit"], stdin: stdin)

      output = context.stdout.to_s
      output.should contain("  2  Break 1  12:55 am - (open)\n")
      output.should contain("  3  Finish   none\n")
      output.should contain("  Break 1 finish  open     › ")
      output.should contain("  Finish  none › ")
      output.should contain("  1  Start    12:50 am  was 12:54 am\n")
      output.should contain("Success: Updated your shift for Tuesday, 17 Feb 2026")
      context.stderr.to_s.should be_empty
    end
  end

  it "warns and skips breaks when they don't have times" do
    travel_to(Time.local(2026, 2, 18, 10, 0)) do
      ClockInSpecHelper.stub_shifts([
        ShiftBuilder.build_shift(
          id: 1,
          start: ClockInSpecHelper::SHIFT_START,
          finish: ClockInSpecHelper::SHIFT_FINISH,
          break_finish: ClockInSpecHelper::BREAK_FINISH,
          break_length: 30,
        ),
      ].to_json)
      ClockInSpecHelper.stub_shift_update(1, {finish: Time.local(2026, 2, 17, 9, 0).to_unix}.to_json)

      stdin = build_stdin("2", "9am", "", "")
      context = run(["clockin", "edit", "--date", "yesterday"], stdin: stdin)

      output = context.stdout.to_s
      output.should contain("Warning: This shift has breaks without times, so they can't be edited here")
      output.should contain("Edit which? 1-2, Enter when done › ")
      output.should_not contain("b to add a break")
      output.should contain("Success: Updated your shift for Tuesday, 17 Feb 2026")
      context.stderr.to_s.should be_empty
    end
  end

  it "errors for a future date" do
    travel_to(Time.local(2026, 2, 17, 18, 0)) do
      context = run(["clockin", "edit", "--date", "2026-02-20"])

      context.stderr.to_s.should eq("Error: Date is in the future!\n       Friday, 20 Feb 2026 hasn't happened yet.\n")
    end
  end
end
