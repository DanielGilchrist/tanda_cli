module Tanda::CLI
  module CLI::Commands
    class RegularHours::Determine
      def initialize(@client : API::Client); end

      def execute
        user = @client.user(id: Current.user.id, show_regular_hours: true, force: true).or(&.display!)
        regular_hours = user.regular_hours

        if regular_hours.nil?
          Utils::Display.error!("Regular hours aren't set for #{user.name}!")
        end

        config = Current.config
        organisation = config.current_environment.current_organisation!

        organisation.regular_hours = regular_hours
        config.save!

        Utils::Display.success("Regular hours set for organisation \"#{organisation.name}\"")
      end
    end
  end
end
