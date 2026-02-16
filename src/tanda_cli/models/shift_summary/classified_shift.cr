require "./leave_shift"
require "./worked_shift"

module TandaCLI
  module Models
    struct ShiftSummary
      alias ClassifiedShift = LeaveShift | WorkedShift
    end
  end
end
