require "../../executors/time_worked/today"

module TandaCLI
  module Commands
    class TimeWorked
      class Today < Commands::Base
        required_scopes :timesheet, :leave

        def setup_
          @name = "today"
          @summary = @description = "Show time worked for today"

          add_option 'd', "display", description: "Print Shift"
          add_option 'o', "offset", type: :single, required: false, description: "Offset from today"
        end

        def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
          display = options.has?("display")
          offset = options.get?("offset").try(&.as_s.to_i32?)

          Executors::TimeWorked::Today.new(context, display, offset).execute
        end
      end
    end
  end
end
