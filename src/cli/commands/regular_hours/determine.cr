module Tanda::CLI
  module CLI::Commands
    class RegularHours::Determine
      def initialize(@client : API::Client); end

      def execute
        determine_from_recent_roster
      end

      private def determine_from_recent_roster(date : Time = Utils::Time.now)
        roster = @client.roster_on_date(date).or(&.display!)

        current_user_id = Current.user.id
        schedules = roster.daily_schedules.flat_map(&.schedules).select do |schedule|
          schedule.user_id == current_user_id
        end

        if schedules.empty?
          Utils::Display.warning("Unable to find roster with schedules for #{date}")
          puts "Would you like to check the week before #{date}? (y/n)"
          response = gets.try(&.chomp)
          Utils::Display.error!("Unable to set regular hours from previous roster") if response != "y"

          previous_week = date - 1.week
          return determine_from_recent_roster(previous_week)
        end

        config = Current.config
        organisation = config.current_environment.current_organisation!

        organisation.set_regular_hours_from_roster!(schedules)
        config.save!

        Utils::Display.success("Regular hours set from roster on #{date}")
      end
    end
  end
end
