require "./spec_helper"

describe TandaCLI::Commands::ClockIn::Break::Finish do
  it "finishes break successfully when on break" do
    ClockInSpecHelper.stub_shifts(ClockInSpecHelper.on_break_shift)
    ClockInSpecHelper.stub_clockin_success

    context = run(["clockin", "break", "finish"])

    context.stdout.to_s.should eq("Success: Your break has ended! (1 | Test Organisation)\n")
    context.stderr.to_s.should be_empty
  end

  it "errors when not clocked in" do
    ClockInSpecHelper.stub_shifts(ClockInSpecHelper.no_shifts)

    context = run(["clockin", "break", "finish"])

    context.stderr.to_s.should eq("Error: You aren't clocked in!\n")
    context.stdout.to_s.should be_empty
  end

  it "errors when clocked in but not on break" do
    ClockInSpecHelper.stub_shifts(ClockInSpecHelper.clocked_in_shift)

    context = run(["clockin", "break", "finish"])

    context.stderr.to_s.should eq("Error: You must start a break to finish a break!\n")
    context.stdout.to_s.should be_empty
  end
end
