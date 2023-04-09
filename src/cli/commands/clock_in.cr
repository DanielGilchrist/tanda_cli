require "./clock_in/determine_status"

module Tanda::CLI
  module CLI::Commands
    class ClockIn
      alias ClockType = CLI::Parser::ClockIn::ClockType

      def initialize(@client : API::Client, @clock_type : ClockType, @skip_validations : Bool = false); end

      def execute
        now = Utils::Time.now

        if skip_validations?
          Utils::Display.warning("Skipping clock in validations")
        else
          ClockInValidator.validate!(client, clock_type, now)
        end

        client.send_clock_in(now, clock_type.to_underscore).or(&.display!)

        display_success_message
      end

      private getter client
      private getter clock_type
      private getter? skip_validations

      private def display_success_message
        success_message =
          case clock_type
          in ClockType::Start
            "You are now clocked in!"
          in ClockType::Finish
            "You are now clocked out!"
          in ClockType::BreakStart
            "Your break has started!"
          in ClockType::BreakFinish
            "Your break has ended!"
          end

        current_user = Current.user
        Utils::Display.success("#{success_message} (#{current_user.id} | #{current_user.organisation_name})")
      end

      private struct ClockInValidator
        def self.validate!(client : API::Client, clock_type : ClockType, now : Time)
          todays_shifts = client.todays_shifts.or(&.display!)
          new(todays_shifts, clock_type).validate!
        end

        def validate!
          case clock_type
          in ClockType::Start
            validate_clockin_start!
          in ClockType::Finish
            validate_clockin_finish!
          in ClockType::BreakStart
            validate_clockin_break_start!
          in ClockType::BreakFinish
            validate_clockin_break_finish!
          end
        end

        # this struct should only be initialized from the `validate!` class method
        private def initialize(@shifts : Array(Types::Shift), @clock_type : ClockType); end

        private getter shifts : Array(Types::Shift)
        private getter clock_type : ClockType

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

        private def break_started? : Bool
          shifts.any?(&.ongoing_break?)
        end

        private def clocked_in? : Bool
          shifts.any? { |shift| shift.start_time && shift.finish_time.nil? }
        end

        private def validate_clockin_start!
          case determine_status
          in ClockInStatus::ClockedIn
            Utils::Display.error!("You are already clocked in!")
          in ClockInStatus::ClockedOut
            return
          in ClockInStatus::BreakStarted
            Utils::Display.error!("You can't clock in when a break has started!")
          end
        end

        private def validate_clockin_finish!
          case determine_status
          in ClockInStatus::ClockedIn
            return
          in ClockInStatus::ClockedOut
            Utils::Display.error!("You haven't clocked in yet!")
          in ClockInStatus::BreakStarted
            Utils::Display.error!("You need to finish your break before clocking out!")
          end
        end

        private def validate_clockin_break_start!
          case determine_status
          in ClockInStatus::ClockedIn
            return
          in ClockInStatus::ClockedOut
            Utils::Display.error!("You need to clock in to start a break!")
          in ClockInStatus::BreakStarted
            Utils::Display.error!("You have already started a break!")
          end
        end

        private def validate_clockin_break_finish!
          case determine_status
          in ClockInStatus::ClockedIn
            Utils::Display.error!("You must start a break to finish a break!")
          in ClockInStatus::ClockedOut
            Utils::Display.error!("You aren't clocked in!")
          in ClockInStatus::BreakStarted
            return
          end
        end
      end
    end
  end
end
