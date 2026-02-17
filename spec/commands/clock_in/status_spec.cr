require "./spec_helper"

describe TandaCLI::Commands::ClockIn::Status do
  it "displays not clocked in when there are no shifts" do
    ClockInSpecHelper.stub_shifts(ClockInSpecHelper.no_shifts)

    context = run(["clockin", "status"])

    context.stdout.to_s.should eq("You aren't currently clocked in\n")
    context.stderr.to_s.should be_empty
  end

  it "displays clocked in with start time when clocked in without breaks" do
    ClockInSpecHelper.stub_shifts(ClockInSpecHelper.clocked_in_shift)

    travel_to(ClockInSpecHelper::SHIFT_START + 6.minutes) do
      context = run(["clockin", "status"])

      pretty_start = TandaCLI::Utils::Time.pretty_time(ClockInSpecHelper::SHIFT_START)
      context.stdout.to_s.should eq("✅ Clocked in\n🕐 Since #{pretty_start}\n")
      context.stderr.to_s.should be_empty
    end
  end

  it "displays on break when there is an ongoing break" do
    ClockInSpecHelper.stub_shifts(ClockInSpecHelper.on_break_shift)

    travel_to(ClockInSpecHelper::BREAK_START + 5.minutes) do
      context = run(["clockin", "status"])

      pretty_break_start = TandaCLI::Utils::Time.pretty_time(ClockInSpecHelper::BREAK_START)
      context.stdout.to_s.should eq("☕ On break\n🕐 Started at #{pretty_break_start}\n")
      context.stderr.to_s.should be_empty
    end
  end

  it "displays clocked in with finished break time when break is finished" do
    ClockInSpecHelper.stub_shifts(ClockInSpecHelper.finished_break_shift)

    travel_to(ClockInSpecHelper::BREAK_FINISH + 5.minutes) do
      context = run(["clockin", "status"])

      pretty_break_finish = TandaCLI::Utils::Time.pretty_time(ClockInSpecHelper::BREAK_FINISH)
      context.stdout.to_s.should eq("✅ Clocked in\n☕ Finished break at #{pretty_break_finish}\n")
      context.stderr.to_s.should be_empty
    end
  end

  it "displays clocked out with finish time when shift is complete" do
    ClockInSpecHelper.stub_shifts(ClockInSpecHelper.clocked_out_shift)

    context = run(["clockin", "status"])

    pretty_finish = TandaCLI::Utils::Time.pretty_time(ClockInSpecHelper::SHIFT_FINISH)
    context.stdout.to_s.should eq("🔴 Clocked out\n🕐 At #{pretty_finish}\n")
    context.stderr.to_s.should be_empty
  end
end
