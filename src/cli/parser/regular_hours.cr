module Tanda::CLI
  class CLI::Parser
    class RegularHours < APIParser
      def parse
        parser.on("determine", "Determine the regular hours for a user") do
          CLI::Executors::RegularHours::Determine.new(client).execute
        end

        # TODO: Make output pretty
        parser.on("display", "Display the regular hours for a user") do
          config = Current.config
          organisation = config.current_environment.current_organisation!
          regular_hours = organisation.regular_hours

          if regular_hours.nil?
            puts "No regular hours set for #{organisation.name}"
            exit
          end

          puts "Regular hours for #{organisation.name}:"
          regular_hours.schedules.each do |schedule|
            puts "  #{schedule.day}: #{schedule.pretty_start_time} - #{schedule.pretty_finish_time}"
            puts "  Breaks:"
            schedule.breaks.each do |break_|
              puts "    #{break_.pretty_start_time} - #{break_.pretty_finish_time}"
              puts "    #{break_.length.minutes} minutes"
            end
            puts
          end
        end
      end
    end
  end
end
