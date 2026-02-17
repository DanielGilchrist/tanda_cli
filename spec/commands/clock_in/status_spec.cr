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

    now = Time.unix(1771290000).in(Time::Location.local)
    travel_to(now) do
      context = run(["clockin", "status"])

      pretty_start = TandaCLI::Utils::Time.pretty_time(Time.unix(1771289640).in(Time::Location.local))
      context.stdout.to_s.should eq("You are clocked in\nYou clocked in at #{pretty_start}\n")
      context.stderr.to_s.should be_empty
    end
  end

  it "displays on break when there is an ongoing break" do
    ClockInSpecHelper.stub_shifts(ClockInSpecHelper.on_break_shift)

    now = Time.unix(1771290000).in(Time::Location.local)
    travel_to(now) do
      context = run(["clockin", "status"])

      pretty_break_start = TandaCLI::Utils::Time.pretty_time(Time.unix(1771289700).in(Time::Location.local))
      context.stdout.to_s.should eq("You are on break\nYou started a break at #{pretty_break_start}\n")
      context.stderr.to_s.should be_empty
    end
  end

  it "displays clocked in with finished break time when break is finished" do
    ClockInSpecHelper.stub_shifts(ClockInSpecHelper.finished_break_shift)

    now = Time.unix(1771291800).in(Time::Location.local)
    travel_to(now) do
      context = run(["clockin", "status"])

      pretty_break_finish = TandaCLI::Utils::Time.pretty_time(Time.unix(1771291500).in(Time::Location.local))
      context.stdout.to_s.should eq("You are clocked in\nYou finished a break at #{pretty_break_finish}\n")
      context.stderr.to_s.should be_empty
    end
  end

  it "displays clocked out with finish time when shift is complete" do
    ClockInSpecHelper.stub_shifts(ClockInSpecHelper.clocked_out_shift)

    context = run(["clockin", "status"])

    pretty_finish = TandaCLI::Utils::Time.pretty_time(Time.unix(1771318440).in(Time::Location.local))
    context.stdout.to_s.should eq("You are clocked out\nYou clocked out at #{pretty_finish}\n")
    context.stderr.to_s.should be_empty
  end
end
