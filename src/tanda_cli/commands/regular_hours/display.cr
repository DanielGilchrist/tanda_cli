module TandaCLI
  module Commands
    struct RegularHours
      @[Kebab::Command(summary: "Display the regular hours for the current user")]
      struct Display
        include Kebab::Parseable

        def run(context : Context) : Nil
          display = context.display
          organisation = context.config.current_organisation!
          regular_hours_schedules = organisation.regular_hours_schedules

          if regular_hours_schedules.empty?
            display.puts "No regular hours set for #{organisation.name}"
            TandaCLI.exit!
          end

          display.puts "📆 Regular hours for #{organisation.name}".colorize.white.bold
          display.puts

          week = Models::RegularHoursWeek.from(regular_hours_schedules)
          week.representer(context.config.start_of_week).display(display)
        end
      end
    end
  end
end
