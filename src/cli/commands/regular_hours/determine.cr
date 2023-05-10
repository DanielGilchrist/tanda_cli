module Tanda::CLI
  module CLI::Commands
    class RegularHours::Determine
      def initialize(@client : API::Client); end

      def execute
        determine_from_user_regular_hours || determine_from_recent_roster
      end

      private def determine_from_user_regular_hours : Bool
        user = @client.user(id: Current.user.id, show_regular_hours: true, force: true).or?
        return false if user.nil?

        regular_hours = user.regular_hours
        return false if regular_hours.nil? || regular_hours.blank?

        config = Current.config
        organisation = config.current_environment.current_organisation!

        organisation.regular_hours = regular_hours
        config.save!

        Utils::Display.success("Regular hours set for organisation \"#{organisation.name}\"")

        true
      end

      private def determine_from_recent_roster(date : Time = Utils::Time.now) : Bool
        # roster = @client.roster_on_date(date).or(&.display!)
        # daily_schedules = roster.daily_schedules

        # if daily_schedules.empty?
        #   previous_week = date - 1.week
        #   return determine_from_recent_roster(previous_week)
        # end
        false
      end
    end
  end
end
