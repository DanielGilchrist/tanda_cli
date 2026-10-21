require "../../spec_helper"

module ClockInSpecHelper
  extend self

  SHIFT_START  = Time.local(2026, 2, 17, 0, 54)
  BREAK_START  = Time.local(2026, 2, 17, 0, 55)
  BREAK_FINISH = Time.local(2026, 2, 17, 1, 25)
  SHIFT_FINISH = Time.local(2026, 2, 17, 8, 54)

  def no_shifts : String
    "[]"
  end

  def clocked_in_shift : String
    [
      ShiftBuilder.build_shift(
        id: 1,
        start: SHIFT_START,
      ),
    ].to_json
  end

  def on_break_shift : String
    [
      ShiftBuilder.build_shift(
        id: 1,
        start: SHIFT_START,
        break_start: BREAK_START,
      ),
    ].to_json
  end

  def finished_break_shift : String
    [
      ShiftBuilder.build_shift(
        id: 1,
        start: SHIFT_START,
        break_start: BREAK_START,
        break_finish: BREAK_FINISH,
        break_length: 30,
      ),
    ].to_json
  end

  def clocked_out_shift : String
    [
      ShiftBuilder.build_shift(
        id: 1,
        start: SHIFT_START,
        finish: SHIFT_FINISH,
      ),
    ].to_json
  end

  def stub_shifts(body : String) : Nil
    WebMock
      .stub(:get, endpoint(Regex.new("/shifts")))
      .to_return(status: 200, body: body)
  end

  def stub_clockin_success : Nil
    WebMock
      .stub(:post, endpoint("/clockins"))
      .to_return(status: 200, body: "{}")
  end

  def stub_shift_update(shift_id : Int32, body : String? = nil) : Nil
    stub = WebMock.stub(:put, endpoint("/shifts/#{shift_id}"))
    stub = stub.with(body: body) if body
    stub.to_return(status: 200, body: "{}")
  end

  def stub_break_update(shift_id : Int32, break_id : Int32, body : String) : Nil
    WebMock
      .stub(:put, endpoint("/shifts/#{shift_id}/breaks/#{break_id}"))
      .with(body: body)
      .to_return(status: 200, body: "{}")
  end

  def stub_break_create(shift_id : Int32, body : String) : Nil
    WebMock
      .stub(:post, endpoint("/shifts/#{shift_id}/breaks"))
      .with(body: body)
      .to_return(status: 200, body: "{}")
  end
end
