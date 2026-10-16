require "../spec_helper"

describe TandaCLI::Models::TimeRange do
  it "Parses a range in several spellings" do
    ["8:30-17:00", "8:30 - 17:00", "8:30am-5pm", "830-1700"].each do |input|
      range = TandaCLI::Models::TimeRange.parse(input).as(TandaCLI::Models::TimeRange)
      range.pretty.should eq("8:30 am - 5:00 pm")
      range.length.should eq(8.5.hours)
    end
  end

  it "Wraps past midnight" do
    range = TandaCLI::Models::TimeRange.parse("22:00-6:00").as(TandaCLI::Models::TimeRange)
    range.overnight?.should be_true
    range.length.should eq(8.hours)
    range.covers?(TandaCLI::Models::TimeRange.parse("2-2:30").as(TandaCLI::Models::TimeRange)).should be_true
    range.covers?(TandaCLI::Models::TimeRange.parse("20-20:30").as(TandaCLI::Models::TimeRange)).should be_false
    range.covers?(TandaCLI::Models::TimeRange.parse("23:30-0:30").as(TandaCLI::Models::TimeRange)).should be_true
  end

  it "Rejects nonsense and empty ranges" do
    TandaCLI::Models::TimeRange.parse("8:30").should be_a(TandaCLI::Error::UnparseableTimeRange)
    TandaCLI::Models::TimeRange.parse("8:30 till 5").should be_a(TandaCLI::Error::UnparseableTimeRange)
    TandaCLI::Models::TimeRange.parse("9-9").should be_a(TandaCLI::Error::EmptyTimeRange)
  end

  it "Renders the typeable form" do
    TandaCLI::Models::TimeRange.parse("8:30am-5pm").to_s.should eq("8:30-17:00")
  end
end
