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
        @clockins_by_type : Hash(Types::ClockIn::Type, Array(Types::ClockIn))? = nil

        def self.validate!(client : API::Client, clock_type : ClockType, now : Time)
          todays_clockins = client.clockins(now).or(&.display!)
          new(todays_clockins, clock_type).validate!
        end

        private def initialize(@clockins : Array(Types::ClockIn), @clock_type : ClockType); end

        private getter clockins : Array(Types::ClockIn)
        private getter clock_type : ClockType

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

        private def validate_clockin_start!
          # If we are currently clocked in we shouldn't clock in again
          return unless clocked_in?

          Utils::Display.error!("You are already clocked in!")
        end

        private def validate_clockin_finish!
          # If we aren't clocked in we shouldn't be clocking out
          if !clocked_in?
            Utils::Display.error!("You haven't clocked in yet!")
          end

          # If a break hasn't been finished we shouldn't be clocking out
          return unless break_started?
          Utils::Display.error!("You need to finish your break before clocking out!")
        end

        private def validate_clockin_break_start!
          # If we're clocked out we shouldn't be able to start a break
          if clocked_out?
            Utils::Display.error!("You need to clock in to start a break!")
          end

          # If we've already started a break we shouldn't be starting another one before finishing
          return unless break_started?
          Utils::Display.error!("You have already started a break!")
        end

        private def validate_clockin_break_finish!
          # If we're clocked out we shouldn't be finishing a break
          if clocked_out?
            Utils::Display.error!("You aren't clocked in!")
          end

          # if we haven't started a break we shouldn't be able to finish one
          return unless break_not_started?
          Utils::Display.error!("You must start a break to finish a break!")
        end

        private def clocked_in? : Bool
          clockins = clockins_for(Types::ClockIn::Type::Start)
          return false if clockins.nil?

          clockouts = clockins_for(Types::ClockIn::Type::Finish)
          return true if clockouts.nil?

          clockins.size > clockouts.size
        end

        private def clocked_out? : Bool
          !clocked_in?
        end

        private def break_started? : Bool
          breaks_started = clockins_for(Types::ClockIn::Type::BreakStart)
          return false if breaks_started.nil?

          breaks_finished = clockins_for(Types::ClockIn::Type::BreakFinish)
          return true if breaks_finished.nil?

          breaks_started.size > breaks_finished.size
        end

        private def break_not_started? : Bool
          !break_started?
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
