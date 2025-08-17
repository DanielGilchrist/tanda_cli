require "../../spec_helper"

describe TandaCLI::Commands::RegularHours::Determine do
  it "Determines and saves regular hours from roster" do
    roster_data = {
      id:        1,
      schedules: [
        {
          date:      "2025-08-04",
          schedules: [
            {
              id:                     1,
              roster_id:              1,
              user_id:                1,
              start:                  Time.local(2025, 8, 4, 8, 30).to_unix,
              finish:                 Time.local(2025, 8, 4, 17, 0).to_unix,
              breaks:                 Array(Hash(String, String)).new,
              automatic_break_length: 30,
              department_id:          1,
              time_zone:              "Europe/London",
              utc_offset:             3600,
            },
          ],
        },
        {
          date:      "2025-08-05",
          schedules: [
            {
              id:                     2,
              roster_id:              1,
              user_id:                1,
              start:                  Time.local(2025, 8, 5, 8, 30).to_unix,
              finish:                 Time.local(2025, 8, 5, 17, 0).to_unix,
              breaks:                 Array(Hash(String, String)).new,
              automatic_break_length: 30,
              department_id:          1,
              time_zone:              "Europe/London",
              utc_offset:             3600,
            },
          ],
        },
      ],
      start:      "2025-08-04",
      finish:     "2025-08-10",
      updated_at: 1724419852,
    }

    WebMock
      .stub(:get, endpoint("/rosters/on/2025-08-05"))
      .to_return(
        status: 200,
        body: roster_data.to_json,
      )

    travel_to(Time.local(2025, 8, 5))

    context = run(["regular_hours", "determine"], config_fixture: :no_regular_hours)

    context.stdout.to_s.should contain("Regular hours set from roster on 2025-08-05")
    context.stderr.to_s.should be_empty

    organisation = context.config.current_organisation!
    organisation.regular_hours_schedules.size.should eq(2)

    monday_schedule = organisation.regular_hours_schedules.find(&.day_of_week.monday?)
    monday_schedule.should_not be_nil
    monday_schedule.try(&.pretty_start_time).should eq("8:30 am")
    monday_schedule.try(&.pretty_finish_time).should eq("5:00 pm")
    monday_schedule.try(&.automatic_break_length).should eq(30)

    tuesday_schedule = organisation.regular_hours_schedules.find(&.day_of_week.tuesday?)
    tuesday_schedule.should_not be_nil
    tuesday_schedule.try(&.pretty_start_time).should eq("8:30 am")
    tuesday_schedule.try(&.pretty_finish_time).should eq("5:00 pm")
    tuesday_schedule.try(&.automatic_break_length).should eq(30)
  end

  it "Errors when user declines to check previous week" do
    WebMock
      .stub(:get, endpoint("/rosters/on/2025-08-04"))
      .to_return(
        status: 200,
        body: {
          id:         123,
          schedules:  [] of Hash(String, String),
          start:      "2025-08-04",
          finish:     "2025-08-04",
          updated_at: 1234567890,
        }.to_json,
      )

    travel_to(Time.local(2025, 8, 4))

    stdin = build_stdin("n")

    context = run(["regular_hours", "determine"], stdin: stdin)

    expected_stdout = <<-OUTPUT
    Warning: Unable to find roster with schedules for 2025-08-04
    Would you like to check the week before 2025-08-04? (y/n)

    OUTPUT

    context.stdout.to_s.should eq(expected_stdout)
    context.stderr.to_s.should eq("Error: Unable to set regular hours from previous roster\n")
  end
end
