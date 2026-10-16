require "../../spec_helper"

describe TandaCLI::Commands::RegularHours::Display do
  it "Displays no regular hours when not set" do
    context = run(["regular_hours", "display"], config_fixture: :no_regular_hours)
    context.stdout.to_s.should eq("No regular hours set for Test Organisation\n")
  end

  it "Displays regular hours as a table in start of week order" do
    context = run(["regular_hours", "display"])

    expected = <<-OUTPUT
      📆 Regular hours for Test Organisation

         Day        Hours              Break  Worked
         Saturday   —                  —      —
         Sunday     —                  —      —
         Monday     8:30 am - 5:00 pm  30min  8h 00m
         Tuesday    8:30 am - 5:00 pm  30min  8h 00m
         Wednesday  8:30 am - 5:00 pm  30min  8h 00m
         Thursday   8:30 am - 5:00 pm  30min  8h 00m
         Friday     8:30 am - 5:00 pm  30min  8h 00m
                                              40h 00m

      OUTPUT

    context.stdout.to_s.should eq(expected)
  end

  it "Displays overnight hours" do
    context = run(["regular_hours", "display"], config_fixture: :overnight_regular_hours)

    stdout = context.stdout.to_s
    stdout.should contain("Monday     10:00 pm - 6:00 am  30min  7h 30m")
    stdout.should_not contain("(overnight)")
  end
end
