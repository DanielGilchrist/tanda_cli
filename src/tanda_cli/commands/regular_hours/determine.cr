module TandaCLI
  module Commands
    struct RegularHours
      @[Kebab::Command(summary: "Determine the regular hours for the current user based on recent rosters")]
      struct Determine
        include Kebab::Parseable

        DEFAULT_WEEKS_TO_CHECK =  8
        MAX_WEEKS_TO_CHECK     = 52

        @[Kebab::Argument(description: "Date to start checking from (YYYY-MM-DD). Defaults to today.")]
        getter date : String?

        @[Kebab::Option(short: 'w', description: "Number of weeks to look back (1-52). Defaults to 8.")]
        getter weeks : Int32 = 8

        def run(context : Context) : Nil
          display = context.display

          starting_date = parse_starting_date(display)
          weeks_to_check = validate_weeks(display)
          dates = (0...weeks_to_check).map { |offset| starting_date - offset.weeks }

          announce_search(display, dates)
          rosters = fetch_rosters(context, dates)
          pattern = Models::RegularHoursPattern.from_rosters(rosters, context.current.user.id)

          display.error!(no_data_message(weeks_to_check)) if pattern.empty?

          pattern.representer.display(display)
          display.puts

          context.input.request_and(message: "Apply these regular hours? (y/n)") do |answer|
            return display.warning("Regular hours not updated") if answer != "y"
          end

          organisation = context.config.current_organisation!
          organisation.replace_regular_hours_schedules!(pattern.to_regular_hours_schedules)
          context.config.save!

          display.success("Regular hours set for #{organisation.name}")
        end

        private def announce_search(display : TandaCLI::Display, dates : Array(Time)) : Nil
          week_word = dates.size == 1 ? "week" : "weeks"
          display.puts "Checking #{dates.size} #{week_word} of rosters (#{Utils::Time.iso_date(dates.last)} → #{Utils::Time.iso_date(dates.first)})..."
          display.puts
        end

        private def fetch_rosters(context : Context, dates : Array(Time)) : Array(API::Types::Roster)
          API::Concurrent
            .fetch(dates) { |date| context.client.rosters.on(date) }
            .map(&.or { |error| context.display.error!(error) })
        end

        private def no_data_message(weeks : Int32) : String
          word = weeks == 1 ? "week" : "weeks"
          "No rosters with schedules found in the last #{weeks} #{word}. Try a larger --weeks value or an earlier date."
        end

        private def parse_starting_date(display : TandaCLI::Display) : Time
          date_string = date
          return Utils::Time.now if date_string.nil?

          begin
            Utils::Time.iso_date(date_string)
          rescue ::Time::Format::Error
            display.error!("Invalid date format \"#{date_string}\". Expected YYYY-MM-DD.")
          end
        end

        private def validate_weeks(display : TandaCLI::Display) : Int32
          if weeks < 1 || weeks > MAX_WEEKS_TO_CHECK
            display.error!("Invalid --weeks value \"#{weeks}\". Must be an integer between 1 and #{MAX_WEEKS_TO_CHECK}.")
          end

          weeks
        end
      end
    end
  end
end
