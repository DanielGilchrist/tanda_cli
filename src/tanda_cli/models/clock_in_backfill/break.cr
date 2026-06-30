module TandaCLI
  module Models
    class ClockInBackfill
      record Break, start : ::Time, finish : ::Time?, paid : Bool
    end
  end
end
