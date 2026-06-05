require "../../spec_helper"

describe TandaCLI::Commands::RegularHours::Determine do
  it "Suggests and saves regular hours when the most recent week has a full schedule" do
    stub_empty_roster_for_dates([
      "2025-07-29",
      "2025-07-22",
      "2025-07-15",
      "2025-07-08",
      "2025-07-01",
      "2025-06-24",
      "2025-06-17",
    ])

    stub_roster("2025-08-05", daily_schedules: [
      daily_schedule(date: "2025-08-04", start: Time.local(2025, 8, 4, 8, 30), finish: Time.local(2025, 8, 4, 17, 0)),
      daily_schedule(date: "2025-08-05", start: Time.local(2025, 8, 5, 8, 30), finish: Time.local(2025, 8, 5, 17, 0)),
    ])

    travel_to(Time.local(2025, 8, 5)) do
      stdin = build_stdin("y")

      context = run(["regular_hours", "determine"], stdin: stdin, config_fixture: :no_regular_hours)

      stdout = context.stdout.to_s
      stdout.should contain("Checking 8 weeks of rosters (2025-06-17 → 2025-08-05)...")
      stdout.should contain("Suggested regular hours (1 of 8 weeks had data):")
      stdout.should contain("Monday")
      stdout.should contain("8:30 am - 5:00 pm")
      stdout.should contain("30min auto")
      stdout.should contain("1 of 8")
      stdout.should contain("Regular hours set for Test Organisation")

      context.stderr.to_s.should be_empty

      organisation = context.config.current_organisation!
      organisation.regular_hours_schedules.size.should eq(2)

      monday_schedule = organisation.regular_hours_schedules.find(&.day_of_week.monday?)
      monday_schedule.should_not be_nil
      monday_schedule.try(&.pretty_start_time).should eq("8:30 am")
      monday_schedule.try(&.pretty_finish_time).should eq("5:00 pm")
      monday_schedule.try(&.automatic_break_length).should eq(30.minutes)
    end
  end

  it "Uses the most recent week's schedule when a day appears in multiple weeks" do
    stub_empty_roster_for_dates([
      "2025-07-22",
      "2025-07-15",
      "2025-07-08",
      "2025-07-01",
      "2025-06-24",
      "2025-06-17",
    ])

    stub_roster("2025-08-05", daily_schedules: [
      daily_schedule(date: "2025-08-04", start: Time.local(2025, 8, 4, 9, 0), finish: Time.local(2025, 8, 4, 17, 30)),
    ])

    stub_roster("2025-07-29", daily_schedules: [
      daily_schedule(date: "2025-07-28", start: Time.local(2025, 7, 28, 8, 30), finish: Time.local(2025, 7, 28, 17, 0)),
    ])

    travel_to(Time.local(2025, 8, 5)) do
      stdin = build_stdin("y")

      context = run(["regular_hours", "determine"], stdin: stdin, config_fixture: :no_regular_hours)

      stdout = context.stdout.to_s
      stdout.should contain("Suggested regular hours (2 of 8 weeks had data):")
      stdout.should contain("9:00 am - 5:30 pm")
      stdout.should contain("2 of 8")

      organisation = context.config.current_organisation!
      organisation.regular_hours_schedules.size.should eq(1)

      monday_schedule = organisation.regular_hours_schedules.find(&.day_of_week.monday?)
      monday_schedule.try(&.pretty_start_time).should eq("9:00 am")
      monday_schedule.try(&.pretty_finish_time).should eq("5:30 pm")
    end
  end

  it "Backfills missing days from older weeks" do
    stub_empty_roster_for_dates([
      "2025-07-22",
      "2025-07-15",
      "2025-07-08",
      "2025-07-01",
      "2025-06-24",
      "2025-06-17",
    ])

    stub_roster("2025-08-05", daily_schedules: [
      daily_schedule(date: "2025-08-04", start: Time.local(2025, 8, 4, 8, 30), finish: Time.local(2025, 8, 4, 17, 0)),
    ])

    stub_roster("2025-07-29", daily_schedules: [
      daily_schedule(date: "2025-07-30", start: Time.local(2025, 7, 30, 9, 0), finish: Time.local(2025, 7, 30, 16, 0)),
    ])

    travel_to(Time.local(2025, 8, 5)) do
      stdin = build_stdin("y")

      context = run(["regular_hours", "determine"], stdin: stdin, config_fixture: :no_regular_hours)

      context.stderr.to_s.should be_empty

      organisation = context.config.current_organisation!
      organisation.regular_hours_schedules.size.should eq(2)

      monday = organisation.regular_hours_schedules.find(&.day_of_week.monday?)
      monday.try(&.pretty_start_time).should eq("8:30 am")

      wednesday = organisation.regular_hours_schedules.find(&.day_of_week.wednesday?)
      wednesday.try(&.pretty_start_time).should eq("9:00 am")
      wednesday.try(&.pretty_finish_time).should eq("4:00 pm")
    end
  end

  it "Does not save when the user declines the suggestion" do
    stub_empty_roster_for_dates([
      "2025-07-29",
      "2025-07-22",
      "2025-07-15",
      "2025-07-08",
      "2025-07-01",
      "2025-06-24",
      "2025-06-17",
    ])

    stub_roster("2025-08-05", daily_schedules: [
      daily_schedule(date: "2025-08-04", start: Time.local(2025, 8, 4, 8, 30), finish: Time.local(2025, 8, 4, 17, 0)),
    ])

    travel_to(Time.local(2025, 8, 5)) do
      stdin = build_stdin("n")

      context = run(["regular_hours", "determine"], stdin: stdin, config_fixture: :no_regular_hours)

      context.stdout.to_s.should contain("Warning: Regular hours not updated")
      context.config.current_organisation!.regular_hours_schedules.should be_empty
    end
  end

  it "Errors when no rosters with schedules are found in the lookback window" do
    stub_empty_roster_for_dates([
      "2025-08-05",
      "2025-07-29",
      "2025-07-22",
      "2025-07-15",
      "2025-07-08",
      "2025-07-01",
      "2025-06-24",
      "2025-06-17",
    ])

    travel_to(Time.local(2025, 8, 5)) do
      context = run(["regular_hours", "determine"], config_fixture: :no_regular_hours)

      context.stderr.to_s.should contain("No rosters with schedules found in the last 8 weeks")
    end
  end

  it "Respects an explicit date argument and the --weeks option" do
    stub_empty_roster_for_dates([
      "2025-05-25",
      "2025-05-18",
    ])

    stub_roster("2025-06-01", daily_schedules: [
      daily_schedule(date: "2025-06-02", start: Time.local(2025, 6, 2, 10, 0), finish: Time.local(2025, 6, 2, 18, 0)),
    ])

    stdin = build_stdin("y")

    context = run(
      ["regular_hours", "determine", "2025-06-01", "--weeks", "3"],
      stdin: stdin,
      config_fixture: :no_regular_hours,
    )

    stdout = context.stdout.to_s
    stdout.should contain("Checking 3 weeks of rosters (2025-05-18 → 2025-06-01)...")
    stdout.should contain("1 of 3")

    monday = context.config.current_organisation!.regular_hours_schedules.find(&.day_of_week.monday?)
    monday.try(&.pretty_start_time).should eq("10:00 am")
  end

  it "Errors on an invalid date argument" do
    context = run(["regular_hours", "determine", "not-a-date"], config_fixture: :no_regular_hours)
    context.stderr.to_s.should contain(%(Invalid date format "not-a-date". Expected YYYY-MM-DD.))
  end

  it "Errors on an invalid --weeks value" do
    context = run(["regular_hours", "determine", "--weeks", "0"], config_fixture: :no_regular_hours)
    context.stderr.to_s.should contain("Invalid --weeks value")
  end
end

private def stub_roster(date_string : String, daily_schedules : Array(JSON::Any) = Array(JSON::Any).new)
  body = JSON.build do |json|
    json.object do
      json.field "id", 1
      json.field "schedules" { daily_schedules.to_json(json) }
      json.field "start", date_string
      json.field "finish", date_string
      json.field "updated_at", 1724419852
    end
  end

  WebMock
    .stub(:get, endpoint("/rosters/on/#{date_string}"))
    .to_return(status: 200, body: body)
end

private def stub_empty_roster_for_dates(date_strings : Array(String))
  date_strings.each { |date_string| stub_roster(date_string) }
end

private def daily_schedule(*, date : String, start : Time, finish : Time, user_id : Int32 = 1, automatic_break_length : Int32 = 30) : JSON::Any
  payload = {
    date:      date,
    schedules: [
      {
        id:                     1,
        roster_id:              1,
        user_id:                user_id,
        start:                  start.to_unix,
        finish:                 finish.to_unix,
        breaks:                 Array(Hash(String, String)).new,
        automatic_break_length: automatic_break_length,
        department_id:          1,
        time_zone:              "Europe/London",
        utc_offset:             3600,
      },
    ],
  }

  JSON.parse(payload.to_json)
end
