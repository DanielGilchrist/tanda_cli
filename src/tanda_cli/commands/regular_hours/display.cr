require "../base"

module TandaCLI
  module Commands
    class RegularHours
      class Display < Base
        def setup_
          @name = "display"
          @summary = @description = "Display the regular hours for a user"
        end

        # TODO: Make output pretty
        def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
          organisation = config.current_organisation!
          regular_hours_schedules = organisation.regular_hours_schedules

          if regular_hours_schedules.nil?
            io.puts "No regular hours set for #{organisation.name}"
            exit
          end

          io.puts "Regular hours for #{organisation.name}:"
          regular_hours_schedules.each do |schedule|
            io.puts "  #{schedule.day_of_week}: #{schedule.pretty_start_time} - #{schedule.pretty_finish_time}"
            if (schedule_breaks = schedule.breaks).present?
              io.puts "  Breaks:"
              schedule_breaks.each do |break_|
                io.puts "    #{break_.pretty_start_time} - #{break_.pretty_finish_time}"
                io.puts "    #{break_.length.minutes} minutes"
              end
            end

            if automatic_break_length = schedule.automatic_break_length
              io.puts "    Automatic break length: #{automatic_break_length} minutes"
            end

            io.puts
          end
        end
      end
    end
  end
end
