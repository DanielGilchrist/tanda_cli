module TandaCLI
  module Models
    class ClockInBackfill
      record Break, start : ::Time, finish : ::Time?
      record FinishedBreak, id : Int32, finish : ::Time
    end
  end
end
