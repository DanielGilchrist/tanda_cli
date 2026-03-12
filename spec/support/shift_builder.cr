module ShiftBuilder
  extend self

  def build_shift(
    id : Int32,
    start : Time? = nil,
    finish : Time? = nil,
    break_start : Time? = nil,
    break_finish : Time? = nil,
    break_length : Int32? = nil,
    break_paid : Bool = false,
    date : Time? = nil,
    leave_request_id : Int32? = nil,
    status : String = "PENDING",
  )
    resolved_date = date || start || Time.local
    breaks =
      if break_start || break_finish
        [
          {
            id:                               1,
            selected_automatic_break_rule_id: nil,
            shift_id:                         id,
            start:                            break_start.try(&.to_unix),
            finish:                           break_finish.try(&.to_unix),
            length:                           break_length || 0,
            paid:                             break_paid,
            updated_at:                       1735259689,
          },
        ]
      else
        [] of NamedTuple(
          id: Int32,
          selected_automatic_break_rule_id: Nil,
          shift_id: Int32,
          start: Int64?,
          finish: Int64?,
          length: Int32,
          paid: Bool,
          updated_at: Int32,
        )
      end

    {
      id:               id,
      timesheet_id:     1,
      user_id:          1,
      date:             TandaCLI::Utils::Time.iso_date(resolved_date),
      start:            start.try(&.to_unix),
      break_start:      break_start.try(&.to_unix),
      break_finish:     break_finish.try(&.to_unix),
      break_length:     break_length,
      breaks:           breaks,
      finish:           finish.try(&.to_unix),
      department_id:    1,
      sub_cost_centre:  nil,
      tag:              nil,
      tag_id:           nil,
      status:           status,
      metadata:         nil,
      leave_request_id: leave_request_id,
      allowances:       [] of Hash(String, String),
      approved_by:      nil,
      approved_at:      nil,
      notes:            [] of Hash(String, String),
      updated_at:       1735259689,
      record_id:        1,
    }
  end

  record DailyBreakdown, shift_id : Int32, date : String, hours : Float64

  def build_leave_request(
    id : Int32,
    shift_id : Int32,
    date : String,
    hours : Float64,
    leave_type : String = "Annual Leave",
    status : String = "approved",
    reason : String? = nil,
  )
    build_leave_request(
      id: id,
      daily_breakdowns: [DailyBreakdown.new(shift_id: shift_id, date: date, hours: hours)],
      leave_type: leave_type,
      status: status,
      reason: reason,
    )
  end

  def build_leave_request(
    id : Int32,
    daily_breakdowns : Array(DailyBreakdown),
    leave_type : String = "Annual Leave",
    status : String = "approved",
    reason : String? = nil,
  )
    shifts = daily_breakdowns.map do |breakdown|
      build_shift(
        id: breakdown.shift_id,
        date: TandaCLI::Utils::Time.iso_date(breakdown.date),
        leave_request_id: id,
      )
    end

    leave_request = {
      id:              id,
      user_id:         1,
      leave_type:      leave_type,
      status:          status,
      reason:          reason,
      daily_breakdown: daily_breakdowns.map do |breakdown|
        {
          id:          breakdown.shift_id.to_s,
          date:        breakdown.date,
          start_time:  nil,
          finish_time: nil,
          hours:       breakdown.hours,
        }
      end,
    }

    {shifts: shifts, leave_request: leave_request}
  end
end
