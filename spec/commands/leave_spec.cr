require "../spec_helper"

private NOW = Time.local(2024, 12, 24)

private def stub_leave(*leave_requests : NamedTuple) : Nil
  stub_leave_body(leave_requests.map { |request| request[:leave_request] }.to_json)
end

private def stub_leave : Nil
  stub_leave_body("[]")
end

private def stub_leave_page(page : Int32, body : String) : Nil
  WebMock
    .stub(:get, endpoint(Regex.new("/leave\\?.*page=#{page}&")))
    .to_return(status: 200, body: body)
end

private def stub_leave_body(body : String) : Nil
  WebMock
    .stub(:get, endpoint(Regex.new("/leave\\?")))
    .to_return(status: 200, body: body)
end

private def christmas_leave : NamedTuple
  ShiftBuilder.build_leave_request(
    id: 1,
    daily_breakdowns: [
      ShiftBuilder::DailyBreakdown.new(shift_id: 10, date: "2024-12-25", hours: 0.0, is_holiday: true),
      ShiftBuilder::DailyBreakdown.new(shift_id: 11, date: "2024-12-26", hours: 8.0),
    ],
    leave_type: "Holiday Leave",
    reason: "Christmas",
  )
end

private def boxing_day_leave : NamedTuple
  ShiftBuilder.build_leave_request(
    id: 3,
    shift_id: 13,
    date: "2024-12-26",
    hours: 8.0,
    leave_type: "Holiday Leave",
    reason: "Boxing Day (auto applied)",
    is_holiday: true,
  )
end

private def sick_leave : NamedTuple
  ShiftBuilder.build_leave_request(
    id: 2,
    shift_id: 12,
    date: "2024-12-02",
    hours: 7.5,
    leave_type: "Sick Leave",
    status: "pending",
  )
end

describe TandaCLI::Commands::Leave do
  describe TandaCLI::Commands::Leave::List do
    it "Lists leave for the year" do
      stub_leave(sick_leave, christmas_leave)

      travel_to(NOW) do
        context = run(["leave", "list"])

        context.stdout.to_s.should eq(<<-OUTPUT)
            DATE                  HOURS  TYPE     STATUS    REASON
            Mon 02 Dec 2024      7h 30m  Sick     Pending
            Wed 25–26 Dec 2024       8h  Holiday  Approved  Christmas

                                15h 30m  2 requests

          OUTPUT
      end
    end

    it "Requests the current calendar year by default" do
      WebMock
        .stub(:get, endpoint("/leave", {
          "from"      => "2024-01-01",
          "to"        => "2024-12-31",
          "user_ids"  => "1",
          "page"      => "1",
          "page_size" => "100",
        }))
        .to_return(status: 200, body: "[]")

      travel_to(NOW) do
        context = run(["leave", "list"])
        context.exit_status.should eq(0)
      end
    end

    it "Follows pagination until a short page comes back" do
      page_size = TandaCLI::API::Resources::LeaveRequests::PAGE_SIZE

      full_page = (1..page_size).map do |index|
        ShiftBuilder.build_leave_request(
          id: index,
          shift_id: index,
          date: "2024-03-01",
          hours: 8.0,
        )[:leave_request]
      end

      stub_leave_page(1, full_page.to_json)
      stub_leave_page(2, [christmas_leave[:leave_request]].to_json)

      travel_to(NOW) do
        context = run(["leave", "list"])
        output = context.stdout.to_s

        output.should contain("Christmas")
        output.scan(/Annual/).size.should eq(page_size)
      end
    end

    it "Marks an auto-applied public holiday and breaks it out of the total" do
      stub_leave(sick_leave, boxing_day_leave)

      travel_to(NOW) do
        context = run(["leave", "list"])
        output = context.stdout.to_s

        output.should contain("· Thu 26 Dec 2024")
        output.should contain("1 auto-applied public holiday (·)")
      end
    end

    it "Filters by status" do
      stub_leave(sick_leave, christmas_leave)

      travel_to(NOW) do
        context = run(["leave", "list", "--status", "pending"])
        output = context.stdout.to_s

        output.should contain("Sick")
        output.should_not contain("Holiday")
      end
    end

    it "Errors on an unknown status" do
      travel_to(NOW) do
        context = run(["leave", "list", "--status", "nope"])

        context.exit_status.should eq(1)
        context.stderr.to_s.should contain("leave status")
      end
    end

    it "Shows leave request ids with --ids" do
      stub_leave(christmas_leave)

      travel_to(NOW) do
        context = run(["leave", "list", "--ids"])
        output = context.stdout.to_s

        output.should contain("ID")
        output.should contain("#1")
      end
    end

    it "Hides auto-applied public holidays with --no-public-holidays" do
      stub_leave(sick_leave, boxing_day_leave)

      travel_to(NOW) do
        context = run(["leave", "list", "--no-public-holidays"])
        output = context.stdout.to_s

        output.should_not contain("Boxing Day")
        output.should contain("1 auto-applied public holiday hidden")
      end
    end

    it "Collapses the status column when every request shares a status" do
      stub_leave(christmas_leave, boxing_day_leave)

      travel_to(NOW) do
        context = run(["leave", "list"])
        output = context.stdout.to_s

        output.should_not contain("STATUS")
        output.should contain("2 requests, all approved")
      end
    end

    it "Says when there's no leave in the window" do
      stub_leave

      travel_to(NOW) do
        context = run(["leave", "list"])

        context.stdout.to_s.should eq("Info: No leave between Monday, 01 Jan 2024 to Tuesday, 31 Dec 2024\n")
      end
    end

    it "Rejects a window longer than the API allows" do
      travel_to(NOW) do
        context = run(["leave", "list", "--from", "2024-01-01", "--to", "2025-12-31"])

        context.exit_status.should eq(1)
        context.stderr.to_s.should contain("too long a period")
      end
    end

    it "Rejects a window that finishes before it starts" do
      travel_to(NOW) do
        context = run(["leave", "list", "--from", "2024-12-31", "--to", "2024-01-01"])

        context.exit_status.should eq(1)
        context.stderr.to_s.should contain("finishes before it starts")
      end
    end
  end

  describe TandaCLI::Commands::Leave::Upcoming do
    it "Shows upcoming leave" do
      stub_leave(christmas_leave)

      travel_to(NOW) do
        context = run(["leave", "upcoming"])
        context.stdout.to_s.should contain("Christmas")
      end
    end

    it "Says when there's no upcoming leave" do
      stub_leave

      travel_to(NOW) do
        context = run(["leave", "upcoming"])
        context.stdout.to_s.should eq("Info: You have no upcoming leave\n")
      end
    end
  end

  describe TandaCLI::Commands::Leave::Taken do
    it "Says when no leave has been taken" do
      stub_leave

      travel_to(NOW) do
        context = run(["leave", "taken"])
        context.stdout.to_s.should eq("Info: You haven't taken any leave in the past year\n")
      end
    end
  end

  describe TandaCLI::Commands::Leave::Show do
    it "Shows a request by id with its breakdown" do
      stub_leave(christmas_leave)

      travel_to(NOW) do
        context = run(["leave", "show", "1"])

        context.stdout.to_s.should eq(<<-OUTPUT)
          Holiday Leave  #1  Approved

            Dates   Wed 25–26 Dec 2024  (2 days, 2 working)
            Hours   8h
            Reason  Christmas

          · Wed 25 Dec     0h  public holiday
            Thu 26 Dec     8h

                           8h

          OUTPUT
      end
    end

    it "Shows leave on a date" do
      stub_leave(christmas_leave)

      travel_to(NOW) do
        context = run(["leave", "show", "2024-12-26"])
        context.stdout.to_s.should contain("Holiday Leave  #1  Approved")
      end
    end

    it "Says when there's no leave on a date" do
      stub_leave

      travel_to(NOW) do
        context = run(["leave", "show", "2024-12-26"])
        context.stdout.to_s.should eq("Info: No leave on Thursday, 26 Dec 2024\n")
      end
    end

    it "Says when no request matches an id" do
      stub_leave

      travel_to(NOW) do
        context = run(["leave", "show", "999"])
        context.stdout.to_s.should eq("Info: No leave request found with id 999\n")
      end
    end

    it "Errors on something that's neither an id nor a date" do
      travel_to(NOW) do
        context = run(["leave", "show", "nonsense"])

        context.exit_status.should eq(1)
        context.stderr.to_s.should contain("doesn't look like a date")
      end
    end
  end
end
