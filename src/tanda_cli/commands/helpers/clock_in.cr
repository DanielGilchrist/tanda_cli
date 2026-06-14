require "./clock_type"

module TandaCLI
  module Commands
    module Helpers
      module ClockIn
        alias ClockType = Helpers::ClockType

        private def execute_clock_in(context : Context, clock_type : ClockType) : Nil
          display = context.display
          time = clock_in_time(context)

          if skip_validations?
            display.warning("Skipping clock in validations")
          else
            check_status!(context, clock_type, time)
          end

          base64_photo = resolve_clockin_photo(context, photo)
          display.error!(base64_photo) if base64_photo.is_a?(Error::Base)

          context.client.clock_ins.create(
            context.current.user.id,
            time,
            clock_type.to_underscore,
            base64_photo,
            mobile_clockin: true
          ).or { |error| display.error!(error) }

          display_clock_in_success(context, clock_type, at ? time : nil)
        end

        private def clock_in_time(context : Context) : Time
          time_of_day = at
          if time_of_day.nil?
            context.display.error!("The --date option can only be used with --at") if date
            return Utils::Time.now
          end

          case moment = Models::ClockInMoment.from(time_of_day, on: date || Utils::Time.now)
          in Models::ClockInMoment
            moment.time
          in Error::Base
            context.display.error!(moment)
          end
        end

        private def check_status!(context : Context, clock_type : ClockType, time : Time)
          display = context.display
          api_shifts = context.client.shifts.list(context.current.user.id, time).or { |error| display.error!(error) }
          shifts = api_shifts.compact_map { |api_shift| Models::WorkedShift.from?(api_shift) }
          status = Models::ClockInStatus.from_shifts(shifts)
          error = status.error_for(clock_type)
          display.error!(error) if error
        end

        private def resolve_clockin_photo(context : Context, clockin_photo : String?) : String? | Error::Base
          if clockin_photo && File.exists?(clockin_photo)
            return Models::Photo.new(clockin_photo).to_base64
          end

          clockin_photo_path = context.config.clockin_photo_path
          return if clockin_photo_path.nil?

          case photo_or_dir = Models::PhotoPathParser.new(clockin_photo_path).parse
          when Models::Photo
            photo_or_dir.to_base64
          when Models::PhotoDirectory
            if clockin_photo
              photo_or_dir.find_photo(clockin_photo).tap do |maybe_photo|
                context.display.warning("No valid photo in #{clockin_photo_path} matching #{clockin_photo}") if maybe_photo.nil?
              end
            else
              photo_or_dir.sample_photo.tap do |maybe_photo|
                context.display.warning("No valid photos found in #{clockin_photo_path}") if maybe_photo.nil?
              end
            end.try(&.to_base64)
          else
            photo_or_dir
          end
        end

        private def display_clock_in_success(context : Context, clock_type : ClockType, backdated_time : Time?) : Nil
          success_message =
            if backdated_time
              "#{clock_type.label} recorded at #{pretty_moment(backdated_time)}!"
            else
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
            end

          current_user = context.current.user
          context.display.success("#{success_message} (#{current_user.id} | #{current_user.organisation_name})")
        end

        private def pretty_moment(time : Time) : String
          pretty_time = Utils::Time.pretty_time(time)
          return pretty_time if time.date == Utils::Time.now.date

          "#{pretty_time} (#{Utils::Time.pretty_date(time)})"
        end
      end
    end
  end
end
