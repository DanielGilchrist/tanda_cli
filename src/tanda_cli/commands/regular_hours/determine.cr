require "../base"

module TandaCLI
  module Commands
    class RegularHours
      class Determine < Base
        requires_auth!

        def setup_
          @name = "determine"
          @summary = @description = "Determine the regular hours for the current user"
        end

        def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
          determine_from_recent_roster
        end

        private def determine_from_recent_roster(date : Time = Utils::Time.now)
          roster = client.roster_on_date(date).or { |error| display.error!(error) }
          current_user_id = current.user.id
          schedules_with_day_of_week = roster.daily_schedules.compact_map do |daily_schedule|
            schedule = daily_schedule.schedules.find(&.user_id.==(current_user_id))
            {day_of_week: daily_schedule.date.day_of_week, schedule: schedule} if schedule
          end

          if schedules_with_day_of_week.empty?
            pretty_date = date.to_s("%Y-%m-%d")
            display.warning("Unable to find roster with schedules for #{pretty_date}")

            input.request_and(message: "Would you like to check the week before #{pretty_date}? (y/n)") do |input|
              display.error!("Unable to set regular hours from previous roster") if input != "y"
            end

            previous_week = date - 1.week
            return determine_from_recent_roster(previous_week)
          end

          organisation = config.current_organisation!
          organisation.set_regular_hours!(schedules_with_day_of_week)
          config.save!

          display.success("Regular hours set from roster on #{date}")
        end
      end
    end
  end
end
