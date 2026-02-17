require "../../spec_helper"

module ClockInSpecHelper
  extend self

  SHIFT_START  = Time.local(2026, 2, 17, 0, 54)
  BREAK_START  = Time.local(2026, 2, 17, 0, 55)
  BREAK_FINISH = Time.local(2026, 2, 17, 1, 25)
  SHIFT_FINISH = Time.local(2026, 2, 17, 8, 54)

  def no_shifts
    "[]"
  end

  def clocked_in_shift
    [
      ShiftBuilder.build_shift(
        id: 1,
        start: SHIFT_START,
      ),
    ].to_json
  end

  def on_break_shift
    [
      ShiftBuilder.build_shift(
        id: 1,
        start: SHIFT_START,
        break_start: BREAK_START,
      ),
    ].to_json
  end

  def finished_break_shift
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

  def clocked_out_shift
    [
      ShiftBuilder.build_shift(
        id: 1,
        start: SHIFT_START,
        finish: SHIFT_FINISH,
      ),
    ].to_json
  end

  def stub_shifts(body : String)
    WebMock
      .stub(:get, endpoint(Regex.new("/shifts")))
      .to_return(status: 200, body: body)
  end

  def stub_clockin_success
    WebMock
      .stub(:post, endpoint("/clockins"))
      .to_return(status: 200, body: "{}")
  end
end
