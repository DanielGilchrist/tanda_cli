require "../../spec_helper"

private def leave_request(breakdown_id : String) : TandaCLI::API::Types::LeaveRequest
  TandaCLI::API::Types::LeaveRequest.from_json({
    id:              1,
    user_id:         1,
    leave_type:      "Annual Leave",
    status:          "pending",
    reason:          nil,
    all_day:         true,
    start:           "2027-01-11",
    finish:          "2027-01-11",
    hours:           8.0,
    daily_breakdown: [{
      id:          breakdown_id,
      date:        "2027-01-11",
      hours:       8.0,
      start_time:  nil,
      finish_time: nil,
      is_holiday:  false,
    }],
  }.to_json)
end

describe TandaCLI::API::Types::LeaveRequest do
  it "Parses pending leave, whose breakdown ids aren't shift ids" do
    breakdown = leave_request("p10606013").daily_breakdown.first

    breakdown.id.should eq("p10606013")
    breakdown.shift_id.should be_nil
  end

  it "Reads the shift id from approved leave" do
    breakdown = leave_request("10606013").daily_breakdown.first

    breakdown.shift_id.should eq(10606013)
  end
end
