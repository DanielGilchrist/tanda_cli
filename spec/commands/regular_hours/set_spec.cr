require "../../spec_helper"

describe TandaCLI::Commands::RegularHours::Set do
  describe "one shot edits" do
    it "Replaces the whole week" do
      context = run(["regular_hours", "set", "mon-fri", "9-17:30", "break", "45m", "--replace"])

      stdout = context.stdout.to_s
      stdout.should contain("* Monday     9:00 am - 5:30 pm  45min  7h 45m")
      stdout.should contain("* Friday     9:00 am - 5:30 pm  45min  7h 45m")
      stdout.should contain("38h 45m")
      stdout.should contain("Success: Regular hours set for Test Organisation")
      context.stderr.to_s.should be_empty

      schedules = context.current_organisation!.regular_hours_schedules
      schedules.size.should eq(5)
      schedules.each do |schedule|
        schedule.pretty_start_time.should eq("9:00 am")
        schedule.automatic_break_length.should eq(45.minutes)
        schedule.breaks.should be_empty
      end
    end

    it "Changes one day's hours and keeps its break" do
      context = run(["regular_hours", "set", "fri", "8:30-16"])

      stdout = context.stdout.to_s
      stdout.should contain("* Friday     8:30 am - 4:00 pm  30min  7h 00m")
      stdout.should contain("39h 00m")
      stdout.should_not contain("Monday")

      friday = context.current_organisation!.regular_hours_schedules.find!(&.day_of_week.friday?)
      friday.pretty_finish_time.should eq("4:00 pm")
      friday.automatic_break_length.should eq(30.minutes)
    end

    it "Accepts the table's own spelling of hours" do
      context = run(["regular_hours", "set", "fri", "8:30", "am", "-", "4:00", "pm", "break", "30min"])

      context.stderr.to_s.should be_empty
      friday = context.current_organisation!.regular_hours_schedules.find!(&.day_of_week.friday?)
      friday.pretty_finish_time.should eq("4:00 pm")
    end

    it "Changes only the breaks" do
      context = run(["regular_hours", "set", "mon-fri", "break", "12-12:30"])

      context.stdout.to_s.should contain("* Monday     8:30 am - 5:00 pm  12:00 pm - 12:30 pm  8h 00m")

      schedules = context.current_organisation!.regular_hours_schedules
      schedules.each do |schedule|
        schedule.automatic_break_length.should eq(0.minutes)
        schedule.breaks.size.should eq(1)
        schedule.breaks.first.pretty_start_time.should eq("12:00 pm")
      end
    end

    it "Sets several fixed breaks" do
      context = run(["regular_hours", "set", "wed", "break", "10-10:15", "12:30-13:00"])

      context.stdout.to_s.should contain("* Wednesday  8:30 am - 5:00 pm  10:00 am - 10:15 am, 12:30 pm - 1:00 pm  7h 45m")
      wednesday = context.current_organisation!.regular_hours_schedules.find!(&.day_of_week.wednesday?)
      wednesday.breaks.size.should eq(2)
    end

    it "Removes a day" do
      context = run(["regular_hours", "set", "fri", "off"])

      context.stdout.to_s.should contain("* Friday     —                  —      —")
      context.stdout.to_s.should contain("32h 00m")
      context.current_organisation!.regular_hours_schedules.map(&.day_of_week).should_not contain(Time::DayOfWeek::Friday)
    end

    it "Copies a day" do
      context = run(["regular_hours", "set", "sat,sun", "same", "as", "mon"])

      context.stdout.to_s.should contain("* Saturday   8:30 am - 5:00 pm  30min  8h 00m")
      context.stdout.to_s.should contain("* Sunday     8:30 am - 5:00 pm  30min  8h 00m")
      context.current_organisation!.regular_hours_schedules.size.should eq(7)
    end

    it "Clears a break" do
      context = run(["regular_hours", "set", "fri", "break", "none"])

      context.stdout.to_s.should contain("* Friday     8:30 am - 5:00 pm  —      8h 30m")
      friday = context.current_organisation!.regular_hours_schedules.find!(&.day_of_week.friday?)
      friday.automatic_break_length.should eq(0.minutes)
      friday.breaks.should be_empty
    end

    it "Sets an overnight shift with a break inside it" do
      context = run(["regular_hours", "set", "mon", "22:00-6:00", "break", "2-2:30"], config_fixture: :overnight_regular_hours)

      context.stderr.to_s.should be_empty
      monday = context.current_organisation!.regular_hours_schedules.find!(&.day_of_week.monday?)
      monday.length.should eq(8.hours)
      monday.breaks.first.pretty_start_time.should eq("2:00 am")
    end

    it "Warns about a shift that looks like a 12 hour clock slip" do
      context = run(["regular_hours", "set", "fri", "9-5"])

      context.stdout.to_s.should contain("9:00 am - 5:00 am (overnight)")
      context.stdout.to_s.should contain("Warning: Friday is 20 hours long. Did you mean 9:00-17:00?")
    end

    it "Prompts for hours and break when only days are given" do
      stdin = build_stdin("8:30-16", "")
      context = run(["regular_hours", "set", "fri"], stdin: stdin)

      stdout = context.stdout.to_s
      stdout.should contain("🕐 Friday hours [8:30-17:00]:")
      stdout.should contain("☕ Friday break [30m]:")
      stdout.should contain("* Friday     8:30 am - 4:00 pm  30min  7h 00m")

      friday = context.current_organisation!.regular_hours_schedules.find!(&.day_of_week.friday?)
      friday.pretty_finish_time.should eq("4:00 pm")
      friday.automatic_break_length.should eq(30.minutes)
    end

    it "Re-asks a prompt after a bad answer" do
      stdin = build_stdin("8:30 till 4", "8:30-16", "none")
      context = run(["regular_hours", "set", "fri"], stdin: stdin)

      context.stderr.to_s.should contain("Unable to parse hours!")
      context.stdout.to_s.scan("🕐 Friday hours").size.should eq(2)
      friday = context.current_organisation!.regular_hours_schedules.find!(&.day_of_week.friday?)
      friday.automatic_break_length.should eq(0.minutes)
    end

    it "Errors on a break for a day without hours" do
      context = run(["regular_hours", "set", "sat", "break", "30m"])

      context.stderr.to_s.should contain("Error: Saturday has no regular hours yet")
      context.stderr.to_s.should contain(%(Give it hours too, e.g. "sat 9-17 break 30m"))
      context.current_organisation!.regular_hours_schedules.size.should eq(5)
    end

    it "Errors on a break without a unit" do
      context = run(["regular_hours", "set", "mon", "9-17", "break", "12"])

      context.stderr.to_s.should contain(%("12" isn't a break))
      context.current_organisation!.regular_hours_schedules.find!(&.day_of_week.monday?).pretty_start_time.should eq("8:30 am")
    end

    it "Errors on a break outside the hours" do
      context = run(["regular_hours", "set", "mon", "9-17", "break", "18-18:30"])

      context.stderr.to_s.should contain("Error: Break 6:00 pm - 6:30 pm is outside Monday's hours (9:00 am - 5:00 pm)")
    end

    it "Errors on overlapping breaks" do
      context = run(["regular_hours", "set", "mon", "break", "12-12:30", "12:15-12:45"])

      context.stderr.to_s.should contain("Error: Breaks 12:00 pm - 12:30 pm and 12:15 pm - 12:45 pm overlap on Monday")
    end

    it "Applies nothing when one day in a multi day edit fails" do
      stdin = build_stdin("wed break 12:30-13", "mon-fri 9-12", "")
      context = run(["regular_hours", "set"], stdin: stdin)

      context.stderr.to_s.should contain("Error: Break 12:30 pm - 1:00 pm is outside Wednesday's hours (9:00 am - 12:00 pm)")
      schedules = context.current_organisation!.regular_hours_schedules
      schedules.each(&.pretty_finish_time.should(eq("5:00 pm")))
      schedules.find!(&.day_of_week.wednesday?).breaks.size.should eq(1)
    end

    it "Errors on an unknown edit" do
      context = run(["regular_hours", "set", "mon", "9-17", "lunch", "30m"])

      context.stderr.to_s.should contain("Unknown edit!")
    end

    it "Refuses to save an empty week" do
      context = run(["regular_hours", "set", "all", "off"])

      context.stderr.to_s.should contain("Nothing to save!")
      context.current_organisation!.regular_hours_schedules.size.should eq(5)
    end
  end

  describe "the edit loop" do
    it "Shows the week, applies edits and saves on a blank line" do
      stdin = build_stdin("fri 8:30-16 break none", "sat 9-13", "")
      context = run(["regular_hours", "set"], stdin: stdin)

      stdout = context.stdout.to_s
      stdout.should contain("📆 Regular hours for Test Organisation")
      stdout.should contain("   Day        Hours              Break  Worked")
      stdout.should contain("Save? (Y/n, type an edit, or ? for help)")
      stdout.should contain("* Friday     8:30 am - 4:00 pm  —      7h 30m")
      stdout.should contain("* Saturday   9:00 am - 1:00 pm  —      4h 00m")
      stdout.should contain("43h 30m")
      stdout.should contain("Success: Regular hours set for Test Organisation")

      schedules = context.current_organisation!.regular_hours_schedules
      schedules.size.should eq(6)
      schedules.find!(&.day_of_week.saturday?).pretty_finish_time.should eq("1:00 pm")
    end

    it "Discards on n" do
      stdin = build_stdin("fri 8:30-16", "n")
      context = run(["regular_hours", "set"], stdin: stdin)

      context.stdout.to_s.should contain("Warning: Regular hours not updated")
      context.current_organisation!.regular_hours_schedules.find!(&.day_of_week.friday?).pretty_finish_time.should eq("5:00 pm")
    end

    it "Discards on end of input" do
      stdin = build_stdin("fri 8:30-16")
      context = run(["regular_hours", "set"], stdin: stdin)

      context.stdout.to_s.should contain("Warning: Regular hours not updated")
      context.current_organisation!.regular_hours_schedules.find!(&.day_of_week.friday?).pretty_finish_time.should eq("5:00 pm")
    end

    it "Prints help, reports bad lines and carries on" do
      stdin = build_stdin("?", "fri 8:30 to 16", "fri 8:30-16", "show", "y")
      context = run(["regular_hours", "set"], stdin: stdin)

      stdout = context.stdout.to_s
      stdout.should contain("Edits are one line, days first:")
      context.stderr.to_s.should contain("Unable to parse hours!")
      stdout.scan("   Day        Hours              Break  Worked").size.should eq(2)
      context.current_organisation!.regular_hours_schedules.find!(&.day_of_week.friday?).pretty_finish_time.should eq("4:00 pm")
    end

    it "Prompts for a bare day inside the loop" do
      stdin = build_stdin("sat", "9-13", "15m", "")
      context = run(["regular_hours", "set"], stdin: stdin)

      context.stdout.to_s.should contain("🕐 Saturday hours [off]:")
      context.stdout.to_s.should contain("☕ Saturday break [none]:")
      saturday = context.current_organisation!.regular_hours_schedules.find!(&.day_of_week.saturday?)
      saturday.automatic_break_length.should eq(15.minutes)
    end
  end

  describe "editing in $EDITOR" do
    it "Opens the week in the editor and saves what comes back" do
      with_editor("replace", "mon-thu 9-17 break 45m\nfri 9-15\nsat,sun off") do
        context = run(["regular_hours", "set"], stdin: build_stdin(""))

        received = editor_received
        received.should contain("# Regular hours for Test Organisation")
        received.should contain("saturday   off")
        received.should contain("monday     8:30-17:00  break 30m")

        stdout = context.stdout.to_s
        stdout.should contain("* Monday     9:00 am - 5:00 pm  45min  7h 15m")
        stdout.should contain("* Friday     9:00 am - 3:00 pm  30min  5h 30m")
        stdout.should contain("Success: Regular hours set for Test Organisation")
        context.stderr.to_s.should be_empty

        schedules = context.current_organisation!.regular_hours_schedules
        schedules.size.should eq(5)
        schedules.find!(&.day_of_week.friday?).pretty_finish_time.should eq("3:00 pm")
      end
    end

    it "Removes days left out of the document" do
      with_editor("replace", "mon-wed 9-17") do
        context = run(["regular_hours", "set"], stdin: build_stdin(""))

        context.stdout.to_s.should contain("* Thursday   —")
        context.current_organisation!.regular_hours_schedules.size.should eq(3)
      end
    end

    it "Cancels when the document comes back empty" do
      with_editor("replace", "# nothing here") do
        context = run(["regular_hours", "set"])

        context.stdout.to_s.should contain("Warning: No changes made")
        context.stdout.to_s.should contain("Warning: Regular hours not updated")
        context.current_organisation!.regular_hours_schedules.size.should eq(5)
      end
    end

    it "Reports problems with line numbers and reopens with them as comments" do
      with_editor("replace", "monday 9-17 break 12\ntuesday\nwednesday 9-17 break 18-18:30") do
        context = run(["regular_hours", "set"], stdin: build_stdin("y", "n"))

        stderr = context.stderr.to_s
        stderr.should contain("Regular hours couldn't be read, 2 problems:")
        context.stdout.to_s.scan("Edit again? (Y/n)").size.should eq(2)
        context.stdout.to_s.should contain("Warning: Regular hours not updated")
        stderr.should contain(%(line 1: "12" isn't a break))
        stderr.should contain("line 2: needs hours")

        received = editor_received
        received.should contain(%(# error: line 1: "12" isn't a break))
        received.should contain("monday 9-17 break 12")
        context.current_organisation!.regular_hours_schedules.find!(&.day_of_week.monday?).pretty_start_time.should eq("8:30 am")
      end
    end

    it "Reports a failing editor" do
      with_editor("fail") do
        context = run(["regular_hours", "set"])

        context.stderr.to_s.should contain("exited with status 1")
        context.stdout.to_s.should contain("Warning: Regular hours not updated")
      end
    end

    it "Opens the editor from the loop with e" do
      with_editor("replace", "sat 9-13") do
        stdin = build_stdin("e", "")
        context = run(["regular_hours", "set"], stdin: stdin)

        context.stdout.to_s.should contain("* Saturday   9:00 am - 1:00 pm  —      4h 00m")
        context.current_organisation!.regular_hours_schedules.size.should eq(1)
      end
    end

    it "Explains when no editor is configured" do
      stdin = build_stdin("e", "n")
      context = run(["regular_hours", "set"], stdin: stdin)

      context.stderr.to_s.should contain("No editor configured")
    end
  end
end
