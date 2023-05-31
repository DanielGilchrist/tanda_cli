require "admiral"

module Tanda::CLI
  class CLI::Commmands
    class Main < Admiral::Command
      define_help description: "tanda_cli"

      def run
        puts help
      end

      register_command me : Me, description: "Get information about yourself"
      register_command personal_details : PersonalDetails, description: "Get your personal details"
      register_command refetch_token : RefetchToken, description: "Refetch token for the current environment"
      register_command refetch_users : RefetchUsers, description: "Refetch users from the API and save to config"
    end
  end
end
