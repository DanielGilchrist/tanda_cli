require "./spec_helper"

describe TandaCLI::Commands::ClockIn::Break::Start do
  it "starts break successfully when clocked in" do
    ClockInSpecHelper.stub_shifts(ClockInSpecHelper.clocked_in_shift)
    ClockInSpecHelper.stub_clockin_success

    context = run(["clockin", "break", "start"])

    context.stdout.to_s.should eq("Success: Your break has started! (1 | Test Organisation)\n")
    context.stderr.to_s.should be_empty
  end

  it "errors when not clocked in" do
    ClockInSpecHelper.stub_shifts(ClockInSpecHelper.no_shifts)

    context = run(["clockin", "break", "start"])

    context.stderr.to_s.should eq("Error: You need to clock in to start a break!\n")
    context.stdout.to_s.should be_empty
  end

  it "errors when already on break" do
    ClockInSpecHelper.stub_shifts(ClockInSpecHelper.on_break_shift)

    context = run(["clockin", "break", "start"])

    context.stderr.to_s.should eq("Error: You have already started a break!\n")
    context.stdout.to_s.should be_empty
  end
end
