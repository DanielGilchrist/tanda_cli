require "../models/photo_path_parser"

module TandaCLI
  module Executors
    class ClockIn
      alias ClockType = Commands::ClockIn::ClockType
      alias Options = Commands::ClockIn::Options

      def initialize(@client : API::Client, @clock_type : ClockType, @options : Options); end

      def execute
        now = Utils::Time.now

        if @options.skip_validations?
          Utils::Display.warning("Skipping clock in validations")
        else
          ClockInValidator.validate!(@client, @clock_type, now)
        end

        clockin_photo = @options.clockin_photo
        base64_photo = begin
          if clockin_photo && File.exists?(clockin_photo)
            Models::Photo.new(clockin_photo).to_base64
          else
            base64_photo_from_clockin_photo_path(clockin_photo)
          end
        end

        case base64_photo
        when Error::Base
          base64_photo.display!
        else
          @client.send_clock_in(now, @clock_type.to_underscore, base64_photo, mobile_clockin: true).or(&.display!)
          display_success_message
        end
      end

      private def base64_photo_from_clockin_photo_path(clockin_photo : String?) : String? | Error::Base
        clockin_photo_path = Current.config.clockin_photo_path
        return if clockin_photo_path.nil?

        case photo_or_dir = Models::PhotoPathParser.new(clockin_photo_path).parse
        when Models::Photo
          photo_or_dir.to_base64
        when Models::PhotoDirectory
          if clockin_photo
            photo_or_dir.find_photo(clockin_photo).tap do |maybe_photo|
              Utils::Display.warning("No valid photo in #{clockin_photo_path} matching #{clockin_photo}") if maybe_photo.nil?
            end
          else
            photo_or_dir.sample_photo.tap do |maybe_photo|
              Utils::Display.warning("No valid photos found in #{clockin_photo_path}") if maybe_photo.nil?
            end
          end.try(&.to_base64)
        else
          photo_or_dir
        end
      end

      private def display_success_message
        success_message =
          case @clock_type
          in .start?
            "You are now clocked in!"
          in .finish?
            "You are now clocked out!"
          in .break_start?
            "Your break has started!"
          in .break_finish?
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
          case @clock_type
          in .start?
            validate_clockin_start!
          in .finish?
            validate_clockin_finish!
          in .break_start?
            validate_clockin_break_start!
          in .break_finish?
            validate_clockin_break_finish!
          end
        end

        # this struct should only be initialized from the `validate!` class method
        private def initialize(@shifts : Array(Types::Shift), @clock_type : ClockType); end

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
          @shifts.any?(&.ongoing_break?)
        end

        private def clocked_in? : Bool
          @shifts.any? { |shift| shift.start_time && shift.finish_time.nil? }
        end

        private def validate_clockin_start!
          case determine_status
          in .clocked_in?
            Utils::Display.error!("You are already clocked in!")
          in .clocked_out?
            return
          in .break_started?
            Utils::Display.error!("You can't clock in when a break has started!")
          end
        end

        private def validate_clockin_finish!
          case determine_status
          in .clocked_in?
            return
          in .clocked_out?
            Utils::Display.error!("You haven't clocked in yet!")
          in .break_started?
            Utils::Display.error!("You need to finish your break before clocking out!")
          end
        end

        private def validate_clockin_break_start!
          case determine_status
          in .clocked_in?
            return
          in .clocked_out?
            Utils::Display.error!("You need to clock in to start a break!")
          in .break_started?
            Utils::Display.error!("You have already started a break!")
          end
        end

        private def validate_clockin_break_finish!
          case determine_status
          in .clocked_in?
            Utils::Display.error!("You must start a break to finish a break!")
          in .clocked_out?
            Utils::Display.error!("You aren't clocked in!")
          in .break_started?
            return
          end
        end
      end
    end
  end
end
