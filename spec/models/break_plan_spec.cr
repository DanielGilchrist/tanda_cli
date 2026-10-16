require "../spec_helper"

describe TandaCLI::Models::BreakPlan do
  it "Parses automatic lengths with a unit" do
    ["30m", "30min", "30 minutes"].each do |input|
      plan = TandaCLI::Models::BreakPlan.parse(input.split(' ')).as(TandaCLI::Models::BreakPlan::Automatic)
      plan.length.should eq(30.minutes)
      plan.pretty.should eq("30min")
    end
  end

  it "Parses fixed ranges" do
    plan = TandaCLI::Models::BreakPlan.parse(["12-12:30", "15-15:15"]).as(TandaCLI::Models::BreakPlan::Fixed)
    plan.ranges.size.should eq(2)
    plan.length.should eq(45.minutes)
    plan.to_s.should eq("12:00-12:30 15:00-15:15")
  end

  it "Parses none and zero" do
    TandaCLI::Models::BreakPlan.parse(["none"]).should be_a(TandaCLI::Models::BreakPlan::None)
    TandaCLI::Models::BreakPlan.parse(["0m"]).should be_a(TandaCLI::Models::BreakPlan::None)
  end

  it "Rejects a bare number, mixed kinds and nonsense" do
    TandaCLI::Models::BreakPlan.parse(["12"]).should be_a(TandaCLI::Error::UnparseableBreak)
    TandaCLI::Models::BreakPlan.parse(["30m", "12-12:30"]).should be_a(TandaCLI::Error::MixedBreaks)
    TandaCLI::Models::BreakPlan.parse(["12-12:30", "30m"]).should be_a(TandaCLI::Error::MixedBreaks)
    TandaCLI::Models::BreakPlan.parse(["lunch"]).should be_a(TandaCLI::Error::UnparseableBreak)
    TandaCLI::Models::BreakPlan.parse([] of String).should be_a(TandaCLI::Error::UnparseableBreak)
  end
end
