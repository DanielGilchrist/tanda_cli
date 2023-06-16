module Tanda::CLI
  class CLI::Parser
    class RegularHours < APIParser
      def parse
        parser.on("determine", "Determine the regular hours for a user") do
          CLI::Commands::RegularHours::Determine.new(client).execute
        end

        # TODO: Make output pretty
        parser.on("display", "Display the regular hours for a user") do
          config = Current.config
          organisation = config.current_environment.current_organisation!
          regular_hours_schedules = organisation.regular_hours_schedules

          if regular_hours_schedules.nil?
            puts "No regular hours set for #{organisation.name}"
            exit
          end

          puts "Regular hours for #{organisation.name}:"
          regular_hours_schedules.each do |schedule|
            puts "  #{schedule.day_of_week}: #{schedule.pretty_start_time} - #{schedule.pretty_finish_time}"
            if !(schedule_breaks = schedule.breaks).empty?
              puts "  Breaks:"
              schedule_breaks.each do |break_|
                puts "    #{break_.pretty_start_time} - #{break_.pretty_finish_time}"
                puts "    #{break_.length.minutes} minutes"
              end
            end

            if automatic_break_length = schedule.automatic_break_length
              puts "Automatic break length: #{automatic_break_length}"
            end
          end
        end
      end
    end
  end
end
