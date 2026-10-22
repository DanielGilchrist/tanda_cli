require "../helpers/leave"
require "../../converters/day"
require "../../error/not_interactive"
require "../../models/leave_breakdown"
require "../../models/leave_draft"
require "../../models/leave_type"
require "../../prompter"
require "../../representers/leave_draft"

module TandaCLI
  module Commands
    struct Leave
      @[Kebab::Command(summary: "Request leave")]
      struct Request
        include Kebab::Parseable
        include Helpers::Leave

        DEFAULT_TYPE = "Holiday Leave"
        CANCELLED    = "Not submitted."

        @[Kebab::Option(short: 'f', converter: ::TandaCLI::Converters::Day, description: "First day (\"fri\", \"tomorrow\" or YYYY-MM-DD)")]
        getter from : Models::ClockInDay?

        @[Kebab::Option(short: 't', converter: ::TandaCLI::Converters::Day, description: "Last day, defaults to the first day")]
        getter to : Models::ClockInDay?

        @[Kebab::Option(description: "Leave type, matched against the types available to you")]
        getter type : String?

        @[Kebab::Option(short: 'r', description: "Reason shown to your approver")]
        getter reason : String?

        @[Kebab::Option(description: "Hours to deduct, defaults to what Tanda recommends")]
        getter hours : Float64?

        @[Kebab::Option(short: 'y', description: "Submit without confirming")]
        getter? yes : Bool = false

        def run(context : Context) : Nil
          display = context.display
          user_id = context.current.user.id
          prompter = Prompter.new(context.input, display)

          window = resolve_request_window(context, prompter)
          leave_type = resolve_type(context, prompter, user_id)
          reason = resolve_reason(context, prompter)

          recommended, existing, balances = API::Concurrent.all(
            -> : API::Result(API::Types::LeaveHours) { context.client.leave_requests.hours_between(user_id, window.from, window.to, leave_type.name) },
            -> : API::Result(Array(API::Types::LeaveRequest)) { context.client.leave_requests.list(user_id, window) },
            -> : API::Result(Array(API::Types::LeaveBalance)) { context.client.leave_balances.list(user_id) },
          )

          hours = resolve_hours(context, recommended)
          draft = Models::LeaveDraft.build(window, leave_type, hours, reason)

          holidays = existing.or { Array(API::Types::LeaveRequest).new }.select(&.public_holiday?)
          balance = balances.or { Array(API::Types::LeaveBalance).new }.find(&.leave_type.==(leave_type.name))
          breakdown = breakdown_for(context, window, holidays, hours)

          prompter.lines do
            Representers::LeaveDraft
              .new(draft, holidays: holidays, balance: balance, breakdown: breakdown, day_length: day_length(context))
              .display(display)
          end

          return declined(display) unless confirmed?(context, prompter)

          created = context.client.leave_requests.create(user_id, draft).or do |error|
            display.error(error)
            return rejected(display, draft)
          end

          display.puts
          display.success("Submitted ##{created.id}")
          display.puts "  tanda_cli leave show #{created.id}"
        end

        private def day_length(context : Context) : Time::Span?
          lengths = context.current_organisation!.regular_hours_schedules.map(&.worked_length).uniq!

          lengths.first if lengths.one?
        end

        private def breakdown_for(
          context : Context,
          window : Models::LeaveWindow,
          holidays : Array(API::Types::LeaveRequest),
          hours : Time::Span,
        ) : Models::LeaveBreakdown::Any?
          named = holidays.to_h do |holiday|
            {holiday.start.at_beginning_of_day, holiday_name(holiday)}
          end

          Models::LeaveBreakdown.for(
            window,
            context.current_organisation!.regular_hours_schedules,
            named,
            hours
          )
        end

        private def holiday_name(holiday : API::Types::LeaveRequest) : String
          reason = holiday.reason
          return Representers::LeaveDraft::HOLIDAY_NOTE if reason.nil? || reason.blank?

          reason.rchop(Representers::LeaveList::AUTO_APPLIED)
        end

        private def resolve_request_window(context : Context, prompter : Prompter) : Models::LeaveWindow
          display = context.display
          start_of_week = context.config.start_of_week
          first = from
          asked = first.nil?

          if first.nil?
            display.error!(Error::NotInteractive.new("Nothing to request", "Pass --from.")) unless context.input.interactive?
            first = ask_first_day(context, prompter)
          end

          start = first.on_or_after_today(start_of_week)
          last = to || (ask_last_day(context, prompter) if asked)
          finish = last ? last.on_or_after_today(start_of_week) : start

          case window = Models::LeaveWindow.between(start, finish)
          in Models::LeaveWindow
            window
          in Error::Base
            display.error!(window)
          end
        end

        private def ask_first_day(context : Context, prompter : Prompter) : Models::ClockInDay
          display = context.display

          loop do
            answer = prompter.ask("First day? fri, tomorrow or YYYY-MM-DD")
            display.error!(CANCELLED) if answer.nil?
            next if answer.blank?

            case day = Models::ClockInDay.parse(answer)
            in Models::ClockInDay
              return day
            in Error::Base
              display.error(day)
            end
          end
        end

        private def ask_last_day(context : Context, prompter : Prompter) : Models::ClockInDay?
          display = context.display

          loop do
            answer = prompter.ask("Last day? Enter for just that day")
            return if answer.nil? || answer.blank?

            case day = Models::ClockInDay.parse(answer)
            in Models::ClockInDay
              return day
            in Error::Base
              display.error(day)
            end
          end
        end

        private def resolve_type(context : Context, prompter : Prompter, user_id : Int32) : Models::LeaveType
          display = context.display

          available = context.client.leave_requests.types_for(user_id).or do |error|
            display.warning("Couldn't fetch your leave types, using \"#{DEFAULT_TYPE}\"")
            display.puts "  #{error.error}"
            return Models::LeaveType.new(DEFAULT_TYPE)
          end

          types = Models::LeaveType.available(available.select(&.named?).map(&.name))
          return Models::LeaveType.new(DEFAULT_TYPE) if types.empty?

          wanted = type
          if wanted
            case parsed = Models::LeaveType.parse(wanted, types)
            in Models::LeaveType
              return parsed
            in Error::Base
              display.error(parsed)
              display.error!(CANCELLED) unless context.input.interactive?
            end
          end

          return types.first if types.one?

          choose_type(context, prompter, types)
        end

        private def choose_type(context : Context, prompter : Prompter, types : Array(Models::LeaveType)) : Models::LeaveType
          display = context.display
          default = types.find(&.name.==(DEFAULT_TYPE)) || types.first

          prompter.lines do
            types.each_with_index(1) do |leave_type, number|
              display.puts "  #{number.colorize.cyan}  #{leave_type.name}"
            end
          end

          loop do
            answer = prompter.ask("Which leave type? 1-#{types.size}, Enter for #{default.name}")
            return default if answer.nil? || answer.blank?

            chosen = answer.to_i?.try { |number| types[number - 1]? if number.positive? }
            return chosen if chosen

            display.error("Pick a number between 1 and #{types.size}")
          end
        end

        private def resolve_reason(context : Context, prompter : Prompter) : String?
          given = reason
          return given if given || !context.input.interactive?

          prompter.ask("Reason? Enter to skip")
        end

        private def resolve_hours(context : Context, recommended : API::Result(API::Types::LeaveHours)) : Time::Span
          override = hours
          return override.hours if override

          recommended.or { |error| context.display.error!(error) }.span
        end

        private def confirmed?(context : Context, prompter : Prompter) : Bool
          return true if yes?

          unless context.input.interactive?
            context.display.error!(Error::NotInteractive.new("Not submitted", "Pass --yes to submit."))
          end

          answer = prompter.ask("Submit? y/N")
          return false if answer.nil?

          answer.strip.downcase.in?("y", "yes")
        end

        private def declined(display : TandaCLI::Display) : Nil
          display.puts
          display.puts CANCELLED
        end

        private def rejected(display : TandaCLI::Display, draft : Models::LeaveDraft) : Nil
          display.puts "#{CANCELLED} To pick this up again:"
          display.puts "  #{draft.retry_command}"

          TandaCLI.fail!
        end
      end
    end
  end
end
