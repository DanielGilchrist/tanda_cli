module TandaCLI
  module Models
    enum ClockInStatus
      ClockedIn
      ClockedOut
      OnBreak

      def self.from_shifts(shifts : Array(Types::Shift)) : self
        if shifts.any?(&.ongoing_break?)
          OnBreak
        elsif shifts.any? { |shift| shift.start_time && shift.finish_time.nil? }
          ClockedIn
        else
          ClockedOut
        end
      end

      def error_for(clock_type : Commands::Helpers::ClockType) : String?
        case clock_type
        in .start?
          error_for_start
        in .finish?
          error_for_finish
        in .break_start?
          error_for_break_start
        in .break_finish?
          error_for_break_finish
        end
      end

      private def error_for_start : String?
        case self
        in .clocked_in?
          "You are already clocked in!"
        in .clocked_out?
          nil
        in .on_break?
          "You can't clock in when a break has started!"
        end
      end

      private def error_for_finish : String?
        case self
        in .clocked_in?
          nil
        in .clocked_out?
          "You haven't clocked in yet!"
        in .on_break?
          "You need to finish your break before clocking out!"
        end
      end

      private def error_for_break_start : String?
        case self
        in .clocked_in?
          nil
        in .clocked_out?
          "You need to clock in to start a break!"
        in .on_break?
          "You have already started a break!"
        end
      end

      private def error_for_break_finish : String?
        case self
        in .clocked_in?
          "You must start a break to finish a break!"
        in .clocked_out?
          "You aren't clocked in!"
        in .on_break?
          nil
        end
      end
    end
  end
end
