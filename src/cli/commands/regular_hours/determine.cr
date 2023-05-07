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

        return false if regular_hours.nil?

        config = Current.config
        organisation = config.current_environment.current_organisation!

        organisation.regular_hours = regular_hours
        config.save!

        Utils::Display.success("Regular hours set for organisation \"#{organisation.name}\"")

        true
      end

      private def determine_from_recent_roster
      end
    end
  end
end
