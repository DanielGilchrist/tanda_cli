require "../base"

module TandaCLI
  module Commands
    class RegularHours
      class Display < Base
        def setup_
          @name = "display"
          @summary = @description = "Display the regular hours for the current user"
        end

        def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
          organisation = config.current_organisation!
          regular_hours_schedules = organisation.regular_hours_schedules

          if regular_hours_schedules.empty?
            stdout.puts "No regular hours set for #{organisation.name}"
            TandaCLI.exit!
          end

          stdout.puts "Regular hours for #{organisation.name}".colorize.white.bold
          stdout.puts

          regular_hours_schedules.each_with_index do |schedule, index|
            hours = "#{schedule.pretty_start_time} - #{schedule.pretty_finish_time}"

            if (automatic_break_length = schedule.automatic_break_length) && automatic_break_length > 0
              break_info = " • #{automatic_break_length}min break"
            end

            stdout.puts "📆 #{schedule.day_of_week}".colorize.white.bold
            stdout.puts "  🕐 #{hours}#{break_info}"

            if (schedule_breaks = schedule.breaks).present?
              schedule_breaks.each do |break_|
                stdout.puts "  ☕ #{break_.pretty_start_time} - #{break_.pretty_finish_time}"
              end
            end

            stdout.puts if index < regular_hours_schedules.size - 1
          end
        end
      end
    end
  end
end
