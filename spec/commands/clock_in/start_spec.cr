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
end
