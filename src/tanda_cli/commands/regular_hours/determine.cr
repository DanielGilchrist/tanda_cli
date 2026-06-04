require "../base"

module TandaCLI
  module Commands
    class RegularHours
      class Determine < Base
        requires_auth!

        DEFAULT_WEEKS_TO_CHECK =  8_u8
        MAX_WEEKS_TO_CHECK     = 52_u8

        def setup_
          @name = "determine"
          @summary = @description = "Determine the regular hours for the current user based on recent rosters"

          add_argument "date",
            description: "Date to start checking from (YYYY-MM-DD). Defaults to today.",
            required: false
          add_option 'w', "weeks",
            type: :single,
            description: "Number of weeks to look back (1-#{MAX_WEEKS_TO_CHECK}). Defaults to #{DEFAULT_WEEKS_TO_CHECK}."
        end

        def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
          starting_date = parse_starting_date(arguments)
          weeks_to_check = parse_weeks_to_check(options)
          dates = (0...weeks_to_check).map { |offset| starting_date - offset.weeks }

          announce_search(dates)
          rosters = fetch_rosters(dates)
          pattern = Models::RegularHoursPattern.from_rosters(rosters, current.user.id)

          display.error!(no_data_message(weeks_to_check)) if pattern.empty?

          pattern.representer.display(display)
          display.puts

          input.request_and(message: "Apply these regular hours? (y/n)") do |answer|
            return display.warning("Regular hours not updated") if answer != "y"
          end

          organisation = config.current_organisation!
          organisation.replace_regular_hours_schedules!(pattern.to_regular_hours_schedules)
          config.save!

          display.success("Regular hours set for #{organisation.name}")
        end

        private def announce_search(dates : Array(Time)) : Nil
          week_word = dates.size == 1 ? "week" : "weeks"
          display.puts "Checking #{dates.size} #{week_word} of rosters (#{Utils::Time.iso_date(dates.last)} → #{Utils::Time.iso_date(dates.first)})..."
          display.puts
        end

        private def fetch_rosters(dates : Array(Time)) : Array(API::Types::Roster)
          API::Concurrent
            .fetch(dates) { |date| client.roster_on_date(date) }
            .map(&.or { |error| display.error!(error) })
        end

        private def no_data_message(weeks : Int32) : String
          word = weeks == 1 ? "week" : "weeks"
          "No rosters with schedules found in the last #{weeks} #{word}. Try a larger --weeks value or an earlier date."
        end

        private def parse_starting_date(arguments : Cling::Arguments) : Time
          date_string = arguments.get?("date").try(&.as_s)
          return Utils::Time.now if date_string.nil?

          begin
            Utils::Time.iso_date(date_string)
          rescue ::Time::Format::Error
            display.error!("Invalid date format \"#{date_string}\". Expected YYYY-MM-DD.")
          end
        end

        private def parse_weeks_to_check(options : Cling::Options) : Int32
          weeks_string = options.get?("weeks").try(&.as_s)
          return DEFAULT_WEEKS_TO_CHECK.to_i32 if weeks_string.nil?

          parsed = weeks_string.to_i32?
          if parsed.nil? || parsed < 1 || parsed > MAX_WEEKS_TO_CHECK
            display.error!("Invalid --weeks value \"#{weeks_string}\". Must be an integer between 1 and #{MAX_WEEKS_TO_CHECK}.")
          end

          parsed
        end
      end
    end
  end
end
