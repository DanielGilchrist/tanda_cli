require "../spec_helper"

private alias Edit = TandaCLI::Models::RegularHoursWeek::Edit

private def parse(line : String) : Edit::Parsed
  Edit.parse(line).as(Edit::Parsed)
end

private def week_of(*lines : String) : TandaCLI::Models::RegularHoursWeek
  lines.reduce(TandaCLI::Models::RegularHoursWeek.empty) do |week, line|
    week.apply(parse(line).as(Edit::Any)).as(TandaCLI::Models::RegularHoursWeek)
  end
end

describe TandaCLI::Models::RegularHoursWeek::Edit do
  it "Parses each form" do
    parse("mon-fri 8:30-17:00 break 30m").should be_a(Edit::Hours)
    parse("fri 8:30-16").as(Edit::Hours).break_plan.should be_nil
    parse("wed break 10-10:15 12:30-13:00").as(Edit::Break).break_plan.should be_a(TandaCLI::Models::BreakPlan::Fixed)
    parse("sat off").should be_a(Edit::Remove)
    parse("tue-fri same as mon").as(Edit::Copy).from.should eq(Time::DayOfWeek::Monday)
    parse("fri").as(Edit::Prompt).days.days.should eq([Time::DayOfWeek::Friday])
  end

  it "Accepts the table spelling and ignores case" do
    edit = parse("Friday 8:30 am - 4:00 pm break 12:00 pm - 12:30 pm").as(Edit::Hours)
    edit.hours.to_s.should eq("8:30-16:00")
    edit.break_plan.to_s.should eq("12:00-12:30")
  end

  it "Rejects malformed lines" do
    Edit.parse("").should be_a(TandaCLI::Error::UnparseableRegularHoursEdit)
    Edit.parse("funday 9-17").should be_a(TandaCLI::Error::UnparseableDaySet)
    Edit.parse("mon 9-17 lunch").should be_a(TandaCLI::Error::UnparseableRegularHoursEdit)
    Edit.parse("mon same as funday").should be_a(TandaCLI::Error::UnparseableDaySet)
    Edit.parse("mon break").should be_a(TandaCLI::Error::UnparseableBreak)
  end
end

describe TandaCLI::Models::RegularHoursWeek do
  it "Builds a week from edits and reports changes" do
    week = week_of("mon-fri 8:30-17:00 break 30m", "fri 8:30-16", "sat 9-13")

    week.to_schedules.map(&.day_of_week.to_s).should eq(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"])
    week.total_worked.should eq(43.hours)
    week.changes_from(week_of("mon-fri 8:30-17:00 break 30m")).should eq([Time::DayOfWeek::Friday, Time::DayOfWeek::Saturday])
  end

  it "Keeps an existing break when only hours change" do
    week = week_of("mon 8:30-17:00 break 12-12:30", "mon 9-17")
    week[Time::DayOfWeek::Monday].as(TandaCLI::Models::RegularHoursSchedule).break_plan.should be_a(TandaCLI::Models::BreakPlan::Fixed)
  end

  it "Applies break edits only to days with hours" do
    week = week_of("mon-wed 9-17", "all break 15m")
    week.to_schedules.size.should eq(3)
    week.to_schedules.each(&.automatic_break_length.should(eq(15.minutes)))
  end

  it "Copies onto days that are off" do
    week = week_of("mon 9-17 break 15m", "sat,sun same as mon")
    week.to_schedules.size.should eq(3)
    week.to_schedules.each(&.automatic_break_length.should(eq(15.minutes)))
  end

  it "Returns errors without applying anything" do
    week = week_of("mon-fri 9-17 break 30m", "wed break 12:30-13")

    week.apply(parse("mon-fri 9-12").as(Edit::Any)).should be_a(TandaCLI::Error::BreakOutsideShift)
    week.apply(parse("sat break 30m").as(Edit::Any)).should be_a(TandaCLI::Error::NoRegularHoursForDay)
    week.apply(parse("sat same as sun").as(Edit::Any)).should be_a(TandaCLI::Error::NoRegularHoursForDay)
    week.apply(parse("mon 9-10 break 60m").as(Edit::Any)).should be_a(TandaCLI::Error::BreakLongerThanShift)
  end

  it "Round trips through the persisted schedule shape" do
    week = week_of("mon 22:00-6:00 break 23:30-0:30 2-2:30")
    reloaded = TandaCLI::Models::RegularHoursWeek.from(Array(TandaCLI::Models::RegularHoursSchedule).from_json(week.to_schedules.to_json))

    reloaded.changes_from(week).should be_empty
    reloaded[Time::DayOfWeek::Monday].as(TandaCLI::Models::RegularHoursSchedule).break_plan.to_s.should eq("23:30-0:30 2:00-2:30")
  end
end
