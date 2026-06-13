module TandaCLI
  module Commands
    struct ClockIn
      struct Photo
        @[Kebab::Command(summary: "View the currently set clockin photo or directory")]
        struct View
          include Kebab::Parseable

          def run(context : Context) : Nil
            message =
              if path = context.config.clockin_photo_path
                "Clock in photo: #{path}"
              else
                "No clock in photo set"
              end

            context.display.puts message
          end
        end
      end
    end
  end
end
