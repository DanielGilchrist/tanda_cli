require "../../commands/helpers/clock_type"

module TandaCLI
  module Models
    class ClockInBackfill
      record Entry, clock_type : Commands::Helpers::ClockType, time : ::Time
    end
  end
end
