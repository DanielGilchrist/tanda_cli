require "../../spec_helper"

private NOW = Time.local(2026, 10, 21)

private def stub_types(body : String = default_types) : Nil
  WebMock
    .stub(:get, endpoint(Regex.new("/leave/types_with_details_for/1")))
    .to_return(status: 200, body: body)
end

private def default_types : String
  [
    {name: "Holiday Leave", default_leave_length: 8.0},
    {name: "Sick Leave", default_leave_length: 8.0},
  ].to_json
end

private def stub_hours(hours : Float64 = 28.0) : Nil
  WebMock
    .stub(:get, endpoint(Regex.new("/leave/hours_between")))
    .to_return(status: 200, body: {hours: hours}.to_json)
end

private def stub_existing(*leave_requests : NamedTuple) : Nil
  stub_existing_body(leave_requests.map { |request| request[:leave_request] }.to_json)
end

private def stub_existing : Nil
  stub_existing_body("[]")
end

private def stub_existing_body(body : String) : Nil
  WebMock
    .stub(:get, endpoint(Regex.new("/leave\\?")))
    .to_return(status: 200, body: body)
end

private def stub_balances(hours : Float64 = 70.0) : Nil
  WebMock
    .stub(:get, endpoint(Regex.new("/leave_balances")))
    .to_return(status: 200, body: [{hours: hours, leave_type: "Holiday Leave"}].to_json)
end

private def stub_create(id : Int32 = 184203) : Nil
  WebMock
    .stub(:post, endpoint("/leave"))
    .to_return(
      status: 200,
      body: ShiftBuilder.build_leave_request(
        id: id,
        shift_id: 1,
        date: "2026-12-21",
        hours: 28.0,
        leave_type: "Holiday Leave",
        status: "pending",
        reason: "Christmas",
      )[:leave_request].to_json
    )
end

private def stub_all(
  types : String? = default_types,
  hours : Float64 = 28.0,
  existing : String = "[]",
  balance : Float64 = 70.0,
  create : Bool = true,
) : Nil
  stub_types(types) if types
  stub_hours(hours)
  stub_existing_body(existing)
  stub_balances(balance)
  stub_create if create
end

describe TandaCLI::Commands::Leave::Request do
  it "Submits a whole-day request with --yes" do
    stub_all

    travel_to(NOW) do
      context = run(["leave", "request", "-f", "2026-12-21", "-t", "2026-12-23", "--type", "holiday", "-r", "Christmas", "--yes"])
      output = context.stdout.to_s

      context.exit_status.should eq(0)
      output.should contain("Holiday Leave  Draft")
      output.should contain("Mon 21 Dec – Wed 23 Dec 2026")
      output.should contain("28h")
      output.should contain("Balance  70h → 42h if approved")
      output.should contain("Success: Submitted #184203")
    end
  end

  it "Treats --from without --to as a single day" do
    stub_all(hours: 7.0)

    travel_to(NOW) do
      context = run(["leave", "request", "-f", "2026-12-21", "--type", "holiday", "--yes"])
      output = context.stdout.to_s

      output.should contain("Mon 21 Dec 2026")
      output.should_not contain("days)")
    end
  end

  it "Names a public holiday inside the range and says it isn't deducted" do
    stub_types
    stub_hours
    stub_balances
    stub_create
    stub_existing(
      ShiftBuilder.build_leave_request(
        id: 99,
        shift_id: 9,
        date: "2026-12-25",
        hours: 8.0,
        leave_type: "Holiday Leave",
        reason: "Christmas Day (auto applied)",
        is_holiday: true,
      )
    )

    travel_to(NOW) do
      context = run(["leave", "request", "-f", "2026-12-21", "-t", "2026-12-25", "--type", "holiday", "--yes"])
      output = context.stdout.to_s

      output.should contain("· Fri 25 Dec  Christmas Day")
    end
  end

  it "Refuses to submit without --yes when stdin isn't a terminal" do
    stub_all

    travel_to(NOW) do
      context = run(["leave", "request", "-f", "2026-12-21", "--type", "holiday"])

      context.exit_status.should eq(1)
      context.stderr.to_s.should contain("Pass --yes to submit")
    end
  end

  it "Refuses to prompt for a missing date when stdin isn't a terminal" do
    stub_all

    travel_to(NOW) do
      context = run(["leave", "request", "--type", "holiday", "--yes"])

      context.exit_status.should eq(1)
      context.stderr.to_s.should contain("Pass --from")
    end
  end

  it "Errors when the leave type doesn't match" do
    stub_all

    travel_to(NOW) do
      context = run(["leave", "request", "-f", "2026-12-21", "--type", "annual", "--yes"])

      context.exit_status.should eq(1)
      context.stderr.to_s.should contain(%(No leave type matches "annual"))
      context.stderr.to_s.should contain("Holiday Leave, Sick Leave")
    end
  end

  it "Falls back to Holiday Leave when the types endpoint fails" do
    WebMock
      .stub(:get, endpoint(Regex.new("/leave/types_with_details_for/1")))
      .to_return(status: 500, body: {error: "boom"}.to_json)

    stub_all(types: nil)

    travel_to(NOW) do
      context = run(["leave", "request", "-f", "2026-12-21", "--yes"])
      output = context.stdout.to_s

      output.should contain("Warning: Couldn't fetch your leave types")
      output.should contain("Holiday Leave  Draft")
    end
  end

  it "Takes the length of a leave day from the API" do
    stub_hours(8.0)
    stub_existing
    stub_balances(70.0)
    stub_create
    stub_types([{name: "Holiday Leave", default_leave_length: 7.0}].to_json)

    travel_to(NOW) do
      context = run(["leave", "request", "-f", "2026-12-21", "--yes"])
      context.stdout.to_s.should contain("Balance  70h (10 days)")
    end
  end

  it "Accepts tomorrow as a date" do
    stub_all

    travel_to(NOW) do
      context = run(["leave", "request", "-f", "tomorrow", "--type", "holiday", "--yes"])
      context.stdout.to_s.should contain("Thu 22 Oct 2026")
    end
  end

  it "Rolls a weekday name forward when it has already passed this week" do
    stub_all

    travel_to(NOW) do
      context = run(["leave", "request", "-f", "monday", "--type", "holiday", "--yes"])
      context.stdout.to_s.should contain("Mon 26 Oct 2026")
    end
  end

  it "Shows a duplicated leave type only once" do
    stub_all(types: [{name: "Holiday Leave"}, {name: "Sick Leave"}, {name: "Holiday Leave"}].to_json)

    travel_to(NOW) do
      context = run(["leave", "request", "-f", "2026-12-21", "--type", "holiday", "--yes"])

      context.exit_status.should eq(0)
      context.stdout.to_s.should contain("Holiday Leave  Draft")
    end
  end

  it "Breaks the request down day by day when it adds up" do
    stub_all(hours: 56.0)

    travel_to(NOW) do
      context = run(["leave", "request", "-f", "2026-10-22", "-t", "2026-11-01", "--type", "holiday", "--yes"])
      output = context.stdout.to_s

      output.should contain("Thu 22 Oct     8h")
      output.should contain("Sat 24 Oct     –")
      output.should contain("56h  7 of 11 days deducted")
    end
  end

  it "Shows a public holiday inside the range as deducting nothing" do
    stub_types
    stub_balances
    stub_create
    stub_hours(48.0)
    stub_existing(
      ShiftBuilder.build_leave_request(
        id: 99,
        shift_id: 9,
        date: "2026-10-26",
        hours: 8.0,
        leave_type: "Holiday Leave",
        reason: "Some Bank Holiday (auto applied)",
        is_holiday: true,
      )
    )

    travel_to(NOW) do
      context = run(["leave", "request", "-f", "2026-10-22", "-t", "2026-11-01", "--type", "holiday", "--yes"])
      output = context.stdout.to_s

      output.should contain("· Mon 26 Oct     –   Some Bank Holiday")
      output.should contain("48h  6 of 11 days deducted")
    end
  end

  it "Omits the breakdown when it doesn't add up to the hours being requested" do
    stub_all(hours: 42.5)

    travel_to(NOW) do
      context = run(["leave", "request", "-f", "2026-10-22", "-t", "2026-11-01", "--type", "holiday", "--yes"])
      output = context.stdout.to_s

      output.should contain("Hours    42h 30m")
      output.should_not contain("days deducted")
    end
  end

  it "Says why there's no breakdown when Tanda's hours disagree with your regular hours" do
    stub_all(hours: 52.0)

    travel_to(NOW) do
      context = run(["leave", "request", "-f", "2026-10-22", "-t", "2026-11-01", "--type", "holiday", "--yes"])
      output = context.stdout.to_s

      output.should contain("Tanda is charging 52h, but your regular hours over these dates come to 56h")
      output.should contain("4h apart")
      output.should_not contain("days deducted")
    end
  end

  it "Says why there's no breakdown when regular hours aren't set" do
    stub_all(hours: 56.0)

    travel_to(NOW) do
      context = run(
        ["leave", "request", "-f", "2026-10-22", "-t", "2026-11-01", "--type", "holiday", "--yes"],
        config_fixture: :no_regular_hours
      )

      context.stdout.to_s.should contain("No day by day breakdown until your regular hours are set")
    end
  end

  it "Needs an explicit choice when none of your leave types is the default" do
    stub_all(types: [{name: "Unpaid Leave"}, {name: "Annual Leave"}].to_json)

    travel_to(NOW) do
      context = interactively do
        run(["leave", "request", "-f", "2026-12-21"], stdin: build_stdin("", "2", "", "y"))
      end

      output = context.stdout.to_s
      output.should contain("Which leave type? 1-2 ")
      output.should_not contain("Enter for")
      output.should contain("Annual Leave  Draft")
      context.stderr.to_s.should contain("Pick a number between 1 and 2")
    end
  end

  it "Right-aligns the leave type numbers" do
    stub_all(types: (1..10).map { |number| {name: "Type #{number}"} }.to_json)

    travel_to(NOW) do
      context = interactively do
        run(["leave", "request", "-f", "2026-12-21"], stdin: build_stdin("1", "", "y"))
      end

      output = context.stdout.to_s
      output.should contain("   1  Type 1")
      output.should contain("  10  Type 10")
    end
  end

  it "Honours an --hours override" do
    stub_all

    travel_to(NOW) do
      context = run(["leave", "request", "-f", "2026-12-21", "--type", "holiday", "--hours", "4", "--yes"])
      context.stdout.to_s.should contain("Hours    4h")
    end
  end

  it "Asks for the last day and builds a range from it" do
    stub_all

    travel_to(NOW) do
      context = interactively do
        run(["leave", "request"], stdin: build_stdin("2026-12-21", "2026-12-23", "", "Christmas", "y"))
      end

      context.stdout.to_s.should contain("Mon 21 Dec – Wed 23 Dec 2026  (3 days)")
    end
  end

  it "Treats an empty last day as a single day" do
    stub_all

    travel_to(NOW) do
      context = interactively do
        run(["leave", "request"], stdin: build_stdin("2026-12-21", "", "", "Christmas", "y"))
      end

      output = context.stdout.to_s
      output.should contain("Dates    Mon 21 Dec 2026")
      output.should_not contain("days)")
    end
  end

  it "Doesn't ask for a last day when --from was given" do
    stub_all

    travel_to(NOW) do
      context = interactively do
        run(["leave", "request", "-f", "2026-12-21", "--type", "holiday"], stdin: build_stdin("", "y"))
      end

      context.stdout.to_s.should_not contain("Last day")
    end
  end

  it "Exits cleanly without a retry line when declined at the confirmation" do
    stub_all

    travel_to(NOW) do
      context = interactively do
        run(["leave", "request", "-f", "2026-12-21", "--type", "holiday", "-r", "Christmas"], stdin: build_stdin("n"))
      end

      context.exit_status.should eq(0)
      context.stdout.to_s.should contain("Not submitted.")
      context.stdout.to_s.should_not contain("tanda_cli leave request --from")
    end
  end

  it "Needs an explicit yes at the confirmation" do
    stub_all

    travel_to(NOW) do
      context = interactively do
        run(["leave", "request", "-f", "2026-12-21", "--type", "holiday", "-r", "Christmas"], stdin: build_stdin(""))
      end

      context.exit_status.should eq(0)
      context.stdout.to_s.should contain("Not submitted.")
      context.stdout.to_s.should_not contain("Success")
    end
  end

  it "Prints a retry command when the API rejects the request" do
    stub_all(create: false)

    WebMock
      .stub(:post, endpoint("/leave"))
      .to_return(status: 400, body: {error: "Invalid", error_description: "Overlaps existing leave"}.to_json)

    travel_to(NOW) do
      context = run(["leave", "request", "-f", "2026-12-21", "--type", "holiday", "-r", "Christmas", "--yes"])

      context.exit_status.should eq(1)
      context.stderr.to_s.should contain("Overlaps existing leave")
      context.stdout.to_s.should contain(%(tanda_cli leave request --from 2026-12-21 --type "Holiday Leave" --reason "Christmas"))
    end
  end
end
