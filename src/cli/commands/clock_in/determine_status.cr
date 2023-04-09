module Tanda::CLI
  module CLI::Commands
    class ClockIn
      # TODO - This is only used for the status command, so it should be moved
      module DetermineStatus
        @clockins_by_type : Hash(Types::ClockIn::Type, Array(Types::ClockIn))? = nil

        private enum ClockInStatus
          ClockedIn
          ClockedOut
          BreakStarted
        end

        private def determine_status : ClockInStatus
          if break_started?
            ClockInStatus::BreakStarted
          elsif clocked_in?
            ClockInStatus::ClockedIn
          else
            ClockInStatus::ClockedOut
          end
        end

        private abstract def clockins : Array(Types::ClockIn)

        private def clocked_in? : Bool
          clockins = clockins_for(Types::ClockIn::Type::Start)
          return false if clockins.nil?

          clockouts = clockins_for(Types::ClockIn::Type::Finish)
          return true if clockouts.nil?

          clockins.size > clockouts.size
        end

        private def break_started? : Bool
          breaks_started = clockins_for(Types::ClockIn::Type::BreakStart)
          return false if breaks_started.nil?

          breaks_finished = clockins_for(Types::ClockIn::Type::BreakFinish)
          return true if breaks_finished.nil?

          breaks_started.size > breaks_finished.size
        end

        private def clockins_for(key : Types::ClockIn::Type) : Array(Types::ClockIn)?
          @clockins_by_type ||= clockins.group_by(&.type)

          clockins_by_type = @clockins_by_type
          clockins_by_type[key]? if clockins_by_type
        end
      end
    end
  end
end
