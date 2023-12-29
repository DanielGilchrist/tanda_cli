require "../../client_builder"
require "../base"

module TandaCLI
  module Commands
    class RegularHours
      class Display < Base
        include ClientBuilder

        def setup_
          @name = "display"
          @summary = @description = "Display the regular hours for a user"
        end

        # TODO: Make output pretty
        def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
          config = Current.config
          organisation = config.current_organisation!
          regular_hours_schedules = organisation.regular_hours_schedules

          if regular_hours_schedules.nil?
            Utils::Display.print "No regular hours set for #{organisation.name}"
            exit
          end

          Utils::Display.print "Regular hours for #{organisation.name}:"
          regular_hours_schedules.each do |schedule|
            Utils::Display.print "  #{schedule.day_of_week}: #{schedule.pretty_start_time} - #{schedule.pretty_finish_time}"
            if !(schedule_breaks = schedule.breaks).empty?
              Utils::Display.print "  Breaks:"
              schedule_breaks.each do |break_|
                Utils::Display.print "    #{break_.pretty_start_time} - #{break_.pretty_finish_time}"
                Utils::Display.print "    #{break_.length.minutes} minutes"
              end
            end

            if automatic_break_length = schedule.automatic_break_length
              Utils::Display.print "    Automatic break length: #{automatic_break_length} minutes"
            end

            puts
          end
        end
      end
    end
  end
end
