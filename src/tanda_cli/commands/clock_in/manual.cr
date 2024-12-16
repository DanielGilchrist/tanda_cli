require "../../client_builder"
require "../../models/clock_in_status"

module TandaCLI
  module Commands
    class ClockIn
      class Manual < Commands::Base
        include ClientBuilder

        required_scopes :timesheet

        def setup_
          @name = "manual"
          @summary = @description = "Manually set shift time for clockin"
        end

        def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
          shifts = client.todays_shifts.or(&.display!)
          status = Models::ClockInStatus.new(shifts).determine_status

          case status
          in .clocked_out?
            handle_clocked_out!
          in .clocked_in?
            puts "Clocked in"
          in .break_started?
            puts "Break started"
          end
        end

        private def handle_clocked_out!
          message = "You are currently clocked out, what do you want to set as the clock in time?"
          time = ask_for_and_parse_time!(message)

          # TODO: Actually create shift and set time
          Utils::Display.success("Set clock in time to #{time}")
        end

        private def ask_for_and_parse_time!(message) : Time
          time_string = Utils::Input.request(message)
          Utils::Display.error!("Input can't be blank!") if time_string.nil?

          time = Utils::Time.parse?(time_string).try(&->time_to_day_time(Time))
          Utils::Display.error!("#{time_string} is not a valid time!") if time.nil?

          puts time
          Utils::Input.request_and(message: "Is this correct?") do |input|
            Utils::Display.error!("Command aborted. Please try again.") if input != "y"
          end

          time
        end

        private def time_to_day_time(time : Time) : Time
          now = Utils::Time.now

          Time.local(
            now.year,
            now.month,
            now.day,
            time.hour,
            time.minute,
            time.second,
            location: now.location
          )
        end
      end
    end
  end
end
