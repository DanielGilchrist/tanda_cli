require "../spec_helper"

private def days(input : String) : Array(Time::DayOfWeek)
  TandaCLI::Models::DaySet.parse(input).as(TandaCLI::Models::DaySet).days
end

describe TandaCLI::Models::DaySet do
  it "Parses names, prefixes, ranges, lists and aliases" do
    days("fri").should eq([Time::DayOfWeek::Friday])
    days("Wednesday").should eq([Time::DayOfWeek::Wednesday])
    days("mon-wed").should eq([Time::DayOfWeek::Monday, Time::DayOfWeek::Tuesday, Time::DayOfWeek::Wednesday])
    days("sat-mon").should eq([Time::DayOfWeek::Saturday, Time::DayOfWeek::Sunday, Time::DayOfWeek::Monday])
    days("mon,wed,mon").should eq([Time::DayOfWeek::Monday, Time::DayOfWeek::Wednesday])
    days("weekdays").size.should eq(5)
    days("weekend").should eq([Time::DayOfWeek::Saturday, Time::DayOfWeek::Sunday])
    days("all").size.should eq(7)
  end

  it "Rejects ambiguous or unknown days" do
    ["t", "tu", "funday", "mon-", ""].each do |input|
      TandaCLI::Models::DaySet.parse(input).should be_a(TandaCLI::Error::UnparseableDaySet)
    end
  end
end
