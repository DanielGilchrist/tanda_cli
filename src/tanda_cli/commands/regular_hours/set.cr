require "../helpers/regular_hours_editing"

module TandaCLI
  module Commands
    struct RegularHours
      @[Kebab::Command(summary: "Set regular hours with one edit, or interactively")]
      struct Set
        include Kebab::Parseable
        include Helpers::RegularHoursEditing

        @[Kebab::Argument(
          description: "Edit, days first: \"mon-fri 8:30-17:00 break 30m\", " \
                       "\"fri break none\", \"sat off\", \"tue-fri same as mon\", " \
                       "or just \"fri\" to be prompted",
        )]
        getter words : Array(String) = [] of String

        @[Kebab::Option(description: "Remove every day not named in this edit")]
        getter? replace : Bool = false

        def run(context : Context) : Nil
          display = context.display
          organisation = context.config.current_organisation!
          saved = Models::RegularHoursWeek.from(organisation.regular_hours_schedules)

          week = words.empty? ? run_loop(context, saved) : run_edit(context, saved)
          return display.warning("Regular hours not updated") if week.nil?

          save_week(context, week)
        end

        private def run_loop(
          context : Context,
          saved : Models::RegularHoursWeek,
        ) : Models::RegularHoursWeek?
          display = context.display
          organisation = context.config.current_organisation!
          prompt = "Save? (Y/n, type an edit, or ? for help)"

          if Editor.from_environment
            week = revise_in_editor(context, saved, saved)
            return if week.nil?

            return edit_loop(context, week, against: saved, prompt: prompt)
          end

          display.puts "📆 Regular hours for #{organisation.name}".colorize.white.bold
          display.puts
          saved.representer(context.config.start_of_week).display(display)
          display.puts

          edit_loop(context, saved, against: saved, prompt: prompt)
        end

        private def run_edit(
          context : Context,
          saved : Models::RegularHoursWeek,
        ) : Models::RegularHoursWeek?
          base = replace? ? Models::RegularHoursWeek.empty : saved

          edited =
            case parsed = Models::RegularHoursWeek::Edit.parse(words.join(' '))
            in Models::RegularHoursWeek::Edit::Prompt
              prompt_for_days(context, base, parsed.days)
            in Models::RegularHoursWeek::Edit::Any
              base.apply(parsed)
            in Error::Base
              parsed
            end

          case edited
          in Models::RegularHoursWeek
            show_changes(context, edited, from: saved, against: saved)
            edited
          in Error::Base
            context.display.error!(edited)
          in Nil
            nil
          end
        end
      end
    end
  end
end
