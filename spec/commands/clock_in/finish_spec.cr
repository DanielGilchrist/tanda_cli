require "./spec_helper"

describe TandaCLI::Commands::ClockIn::Finish do
  it "clocks out successfully when clocked in" do
    ClockInSpecHelper.stub_shifts(ClockInSpecHelper.clocked_in_shift)
    ClockInSpecHelper.stub_clockin_success

    context = run(["clockin", "finish"])

    context.stdout.to_s.should eq("Success: You are now clocked out! (1 | Test Organisation)\n")
    context.stderr.to_s.should be_empty
  end

  it "errors when not clocked in" do
    ClockInSpecHelper.stub_shifts(ClockInSpecHelper.no_shifts)

    context = run(["clockin", "finish"])

    context.stderr.to_s.should eq("Error: You haven't clocked in yet!\n")
    context.stdout.to_s.should be_empty
  end

  it "errors when on break" do
    ClockInSpecHelper.stub_shifts(ClockInSpecHelper.on_break_shift)

    context = run(["clockin", "finish"])

    context.stderr.to_s.should eq("Error: You need to finish your break before clocking out!\n")
    context.stdout.to_s.should be_empty
  end

  it "updates the existing open shift when clocking out on a previous day" do
    travel_to(Time.local(2026, 2, 18, 10, 0)) do
      ClockInSpecHelper.stub_shifts(ClockInSpecHelper.clocked_in_shift)
      ClockInSpecHelper.stub_shift_update(1, {finish: Time.local(2026, 2, 17, 17, 30).to_unix}.to_json)

      context = run(["clockin", "finish", "--at", "5:30pm", "--date", "yesterday"])

      context.stdout.to_s.should eq("Success: Clock out recorded at 5:30 pm (Tuesday, 17 Feb 2026)! (1 | Test Organisation)\n")
      context.stderr.to_s.should be_empty
    end
  end
end
