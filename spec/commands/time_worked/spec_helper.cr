require "../../spec_helper"

module TimeWorkedSpecHelper
  extend self

  def stub_shifts(body : String) : Nil
    WebMock
      .stub(:get, endpoint(Regex.new("/shifts")))
      .to_return(status: 200, body: body)
  end

  def stub_leave_requests(body : String) : Nil
    WebMock
      .stub(:get, endpoint(Regex.new("/leave")))
      .to_return(status: 200, body: body)
  end

  def stub_leave_requests(*leave_requests : NamedTuple, worked_shifts : Array(NamedTuple)? = nil) : Nil
    leave_shifts = leave_requests.flat_map { |request| request[:shifts] }
    all_shifts =
      if worked_shifts
        (worked_shifts + leave_shifts).sort_by { |shift| shift[:date] }
      else
        leave_shifts
      end

    stub_shifts(all_shifts.to_json)
    stub_leave_requests(leave_requests.map { |request| request[:leave_request] }.to_json)
  end
end
