require "../spec_helper"

private def week_of(*lines : String) : TandaCLI::Models::RegularHoursWeek
  lines.reduce(TandaCLI::Models::RegularHoursWeek.empty) do |week, line|
    edit = TandaCLI::Models::RegularHoursWeek::Edit.parse(line).as(TandaCLI::Models::RegularHoursWeek::Edit::Any)
    week.apply(edit).as(TandaCLI::Models::RegularHoursWeek)
  end
end

describe TandaCLI::Models::RegularHoursDocument do
  it "Renders a week that parses back to itself" do
    week = week_of("mon-thu 8:30-17:00 break 30m", "fri 8:30-16 break 12-12:30 15-15:15", "sat 22:00-6:00")
    text = TandaCLI::Models::RegularHoursDocument.render(week, Time::DayOfWeek::Monday, "Test")

    text.should contain("# Test\n")
    text.should contain("friday     8:30-16:00  break 12:00-12:30 15:00-15:15\n")
    text.should contain("saturday   22:00-6:00\n")
    text.should contain("sunday     off\n")

    document = TandaCLI::Models::RegularHoursDocument.parse(text).as(TandaCLI::Models::RegularHoursDocument)
    reparsed = document.apply_to(TandaCLI::Models::RegularHoursWeek.empty).as(TandaCLI::Models::RegularHoursWeek)
    reparsed.changes_from(week).should be_empty
  end

  it "Applies against the current week and drops unmentioned days" do
    week = week_of("mon-fri 8:30-17:00 break 30m")
    document = TandaCLI::Models::RegularHoursDocument.parse("mon-wed break 15m\n# fri stays out\n").as(TandaCLI::Models::RegularHoursDocument)

    revised = document.apply_to(week).as(TandaCLI::Models::RegularHoursWeek)
    revised.to_schedules.size.should eq(3)
    revised.to_schedules.each(&.automatic_break_length.should(eq(15.minutes)))
  end

  it "Collects every parse problem with its line" do
    error = TandaCLI::Models::RegularHoursDocument.parse("mon 9-17\nfunday 9-17\n\ntue\n").as(TandaCLI::Error::InvalidRegularHoursDocument)

    error.problems.map(&.line).should eq([2, 4])
    error.as_comments.lines.first.should start_with(%(# error: line 2: "funday"))
  end

  it "Reports an apply problem with its line" do
    error = TandaCLI::Models::RegularHoursDocument.parse("mon 9-17\ntue same as sun")
      .as(TandaCLI::Models::RegularHoursDocument)
      .apply_to(TandaCLI::Models::RegularHoursWeek.empty)
      .as(TandaCLI::Error::InvalidRegularHoursDocument)

    error.problems.first.line.should eq(2)
    error.problems.first.message.should contain("Sunday has no regular hours yet")
  end
end
