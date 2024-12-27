require "../models/photo_path_parser"

module TandaCLI
  module Executors
    class ClockIn
      alias ClockType = Commands::ClockIn::ClockType
      alias Options = Commands::ClockIn::Options

      def initialize(@context : Context, @clock_type : ClockType, @options : Options); end

      def execute
        now = Utils::Time.now

        if @options.skip_validations?
          @context.display.warning("Skipping clock in validations")
        else
          ClockInValidator.validate!(@context, @clock_type, now)
        end

        clockin_photo = @options.clockin_photo
        base64_photo = begin
          if clockin_photo && File.exists?(clockin_photo)
            Models::Photo.new(clockin_photo).to_base64
          else
            base64_photo_from_clockin_photo_path(clockin_photo)
          end
        end

        @context.display.error!(base64_photo) if base64_photo.is_a?(Error::Base)

        @context.client.send_clock_in(
          @context.current.user.id,
          now,
          @clock_type.to_underscore,
          base64_photo,
          mobile_clockin: true
        ).or { |error| @context.display.error!(error) }

        display_success_message
      end

      private def base64_photo_from_clockin_photo_path(clockin_photo : String?) : String? | Error::Base
        clockin_photo_path = @context.config.clockin_photo_path
        return if clockin_photo_path.nil?

        case photo_or_dir = Models::PhotoPathParser.new(clockin_photo_path).parse
        when Models::Photo
          photo_or_dir.to_base64
        when Models::PhotoDirectory
          if clockin_photo
            photo_or_dir.find_photo(clockin_photo).tap do |maybe_photo|
              @context.display.warning("No valid photo in #{clockin_photo_path} matching #{clockin_photo}") if maybe_photo.nil?
            end
          else
            photo_or_dir.sample_photo.tap do |maybe_photo|
              @context.display.warning("No valid photos found in #{clockin_photo_path}") if maybe_photo.nil?
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

        current_user = @context.current.user
        @context.display.success("#{success_message} (#{current_user.id} | #{current_user.organisation_name})")
      end

      private struct ClockInValidator
        def self.validate!(context : Context, clock_type : ClockType, now : Time)
          todays_shifts = context.client.shifts(context.current.user.id, Utils::Time.now).or { |error| context.display.error!(error) }
          new(context, todays_shifts, clock_type).validate!
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
        private def initialize(@context : Context, @shifts : Array(Types::Shift), @clock_type : ClockType); end

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
            @context.display.error!("You are already clocked in!")
          in .clocked_out?
            return
          in .break_started?
            @context.display.error!("You can't clock in when a break has started!")
          end
        end

        private def validate_clockin_finish!
          case determine_status
          in .clocked_in?
            return
          in .clocked_out?
            @context.display.error!("You haven't clocked in yet!")
          in .break_started?
            @context.display.error!("You need to finish your break before clocking out!")
          end
        end

        private def validate_clockin_break_start!
          case determine_status
          in .clocked_in?
            return
          in .clocked_out?
            @context.display.error!("You need to clock in to start a break!")
          in .break_started?
            @context.display.error!("You have already started a break!")
          end
        end

        private def validate_clockin_break_finish!
          case determine_status
          in .clocked_in?
            @context.display.error!("You must start a break to finish a break!")
          in .clocked_out?
            @context.display.error!("You aren't clocked in!")
          in .break_started?
            return
          end
        end
      end
    end
  end
end
