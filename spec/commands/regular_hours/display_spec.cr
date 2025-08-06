require "../../spec_helper"

describe TandaCLI::Commands::RegularHours::Display do
  it "Displays no regular hours when not set" do
    context = run(["regular_hours", "display"], config_fixture: :no_regular_hours)
    context.stdout.to_s.should eq("No regular hours set for Test Organisation\n")
  end

  it "Displays regular hours with automatic breaks" do
    context = run(["regular_hours", "display"])

    expected = <<-OUTPUT
    Regular hours for Test Organisation

    📆 Monday
      🕐 8:30 am - 5:00 pm • 30min break

    📆 Tuesday
      🕐 8:30 am - 5:00 pm • 30min break

    📆 Wednesday
      🕐 8:30 am - 5:00 pm • 30min break

    📆 Thursday
      🕐 8:30 am - 5:00 pm • 30min break

    📆 Friday
      🕐 8:30 am - 5:00 pm • 30min break

    OUTPUT

    context.stdout.to_s.should eq(expected)
  end
end
