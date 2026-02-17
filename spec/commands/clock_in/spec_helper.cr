require "../../spec_helper"

module ClockInSpecHelper
  extend self

  def no_shifts
    "[]"
  end

  def clocked_in_shift
    [
      {
        id:               34447851,
        timesheet_id:     7913528,
        user_id:          1,
        date:             "2026-02-17",
        start:            1771289640,
        break_start:      nil,
        break_finish:     nil,
        break_length:     0,
        breaks:           [] of Nil,
        finish:           nil,
        department_id:    8683,
        sub_cost_centre:  nil,
        tag:              nil,
        tag_id:           nil,
        status:           "PENDING",
        metadata:         nil,
        leave_request_id: nil,
        allowances:       [] of Nil,
        approved_by:      nil,
        approved_at:      nil,
        updated_at:       1771289684,
        record_id:        63879572,
      },
    ].to_json
  end

  def on_break_shift
    [
      {
        id:           34447851,
        timesheet_id: 7913528,
        user_id:      1,
        date:         "2026-02-17",
        start:        1771289640,
        break_start:  1771289700,
        break_finish: nil,
        break_length: 0,
        breaks:       [
          {
            id:                               6515655,
            selected_automatic_break_rule_id: nil,
            shift_id:                         34447851,
            start:                            1771289700,
            finish:                           nil,
            length:                           0,
            paid:                             false,
            updated_at:                       1771289750,
          },
        ],
        finish:           nil,
        department_id:    8683,
        sub_cost_centre:  nil,
        tag:              nil,
        tag_id:           nil,
        status:           "PENDING",
        metadata:         nil,
        leave_request_id: nil,
        allowances:       [] of Nil,
        approved_by:      nil,
        approved_at:      nil,
        updated_at:       1771289684,
        record_id:        63879572,
      },
    ].to_json
  end

  def finished_break_shift
    [
      {
        id:           34447851,
        timesheet_id: 7913528,
        user_id:      1,
        date:         "2026-02-17",
        start:        1771289640,
        break_start:  1771289700,
        break_finish: 1771291500,
        break_length: 30,
        breaks:       [
          {
            id:                               6515655,
            selected_automatic_break_rule_id: nil,
            shift_id:                         34447851,
            start:                            1771289700,
            finish:                           1771291500,
            length:                           30,
            paid:                             false,
            updated_at:                       1771291500,
          },
        ],
        finish:           nil,
        department_id:    8683,
        sub_cost_centre:  nil,
        tag:              nil,
        tag_id:           nil,
        status:           "PENDING",
        metadata:         nil,
        leave_request_id: nil,
        allowances:       [] of Nil,
        approved_by:      nil,
        approved_at:      nil,
        updated_at:       1771291500,
        record_id:        63879572,
      },
    ].to_json
  end

  def clocked_out_shift
    [
      {
        id:               34447851,
        timesheet_id:     7913528,
        user_id:          1,
        date:             "2026-02-17",
        start:            1771289640,
        break_start:      nil,
        break_finish:     nil,
        break_length:     0,
        breaks:           [] of Nil,
        finish:           1771318440,
        department_id:    8683,
        sub_cost_centre:  nil,
        tag:              nil,
        tag_id:           nil,
        status:           "PENDING",
        metadata:         nil,
        leave_request_id: nil,
        allowances:       [] of Nil,
        approved_by:      nil,
        approved_at:      nil,
        updated_at:       1771318440,
        record_id:        63879572,
      },
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
