require "../clock_in"

module TandaCLI
  module Commands
    module Helpers
      module ClockIn
        alias ClockType = Helpers::ClockType

        private def execute_clock_in(clock_type : ClockType, options : Commands::ClockIn::Options) : Nil
          now = Utils::Time.now

          if options.skip_validations?
            display.warning("Skipping clock in validations")
          else
            check_status!(clock_type, now)
          end

          base64_photo = resolve_clockin_photo(options.clockin_photo)
          display.error!(base64_photo) if base64_photo.is_a?(Error::Base)

          client.send_clock_in(
            current.user.id,
            now,
            clock_type.to_underscore,
            base64_photo,
            mobile_clockin: true
          ).or { |error| display.error!(error) }

          display_clock_in_success(clock_type)
        end

        private def check_status!(clock_type : ClockType, now : Time)
          shifts = client.shifts(current.user.id, now).or { |error| display.error!(error) }
          status = Models::ClockInStatus.from_shifts(shifts)
          error = status.error_for(clock_type)
          display.error!(error) if error
        end

        private def resolve_clockin_photo(clockin_photo : String?) : String? | Error::Base
          if clockin_photo && File.exists?(clockin_photo)
            return Models::Photo.new(clockin_photo).to_base64
          end

          clockin_photo_path = config.clockin_photo_path
          return if clockin_photo_path.nil?

          case photo_or_dir = Models::PhotoPathParser.new(clockin_photo_path).parse
          when Models::Photo
            photo_or_dir.to_base64
          when Models::PhotoDirectory
            if clockin_photo
              photo_or_dir.find_photo(clockin_photo).tap do |maybe_photo|
                display.warning("No valid photo in #{clockin_photo_path} matching #{clockin_photo}") if maybe_photo.nil?
              end
            else
              photo_or_dir.sample_photo.tap do |maybe_photo|
                display.warning("No valid photos found in #{clockin_photo_path}") if maybe_photo.nil?
              end
            end.try(&.to_base64)
          else
            photo_or_dir
          end
        end

        private def display_clock_in_success(clock_type : ClockType) : Nil
          success_message =
            case clock_type
            in .start?
              "You are now clocked in!"
            in .finish?
              "You are now clocked out!"
            in .break_start?
              "Your break has started!"
            in .break_finish?
              "Your break has ended!"
            end

          current_user = current.user
          display.success("#{success_message} (#{current_user.id} | #{current_user.organisation_name})")
        end
      end
    end
  end
end
