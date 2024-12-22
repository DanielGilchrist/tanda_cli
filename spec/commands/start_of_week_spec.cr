require "../spec_helper"

describe TandaCLI::Commands::StartOfWeek do
  describe TandaCLI::Commands::StartOfWeek::Display do
    it "Displays currently set start_of_week" do
      context = Command.run(["start_of_week", "display"])
      context.io.to_s.should eq("Start of the week is set to Saturday\n")
    end
  end

  describe TandaCLI::Commands::StartOfWeek::Set do
    it "Sets start of week" do
      start_of_week = "Monday"
      context = Command.run(["start_of_week", "set", start_of_week])
      context.config.start_of_week.should eq(Time::DayOfWeek::Monday)
      context.io.to_s.should eq("Success: Start of the week set to #{start_of_week}\n")
    end

    it "Doesn't set start of week if invalid value is passed" do
      start_of_week = "invalid"
      context = Command.run(["start_of_week", "set", start_of_week])
      context.config.start_of_week.should eq(Time::DayOfWeek::Saturday)

      expected = <<-OUTPUT
      Error: Invalid start of week!
             "invalid" is not a valid day of the week.

      OUTPUT

      context.io.to_s.should eq(expected)
    end
  end
end
