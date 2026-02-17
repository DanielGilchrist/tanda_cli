require "../../spec_helper"

module TimeWorkedSpecHelper
  extend self

  def stub_shifts(body : String)
    WebMock
      .stub(:get, endpoint(Regex.new("/shifts")))
      .to_return(status: 200, body: body)
  end

  def stub_leave_requests(body : String)
    WebMock
      .stub(:get, endpoint(Regex.new("/leave")))
      .to_return(status: 200, body: body)
  end
end
