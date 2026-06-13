module TandaCLI
  module Commands
    struct ClockIn
      struct Photo
        @[Kebab::Command(name: "set", summary: "Set a default clockin photo or directory of photos")]
        struct Set
          include Kebab::Serialisable

          @[Kebab::Argument(description: "Path to the photo or directory of photos to set")]
          getter path : String

          def run(context : Context) : Nil
            if !Models::PhotoPathParser.valid?(path)
              context.display.error!("Invalid photo path")
            end

            context.config.clockin_photo_path = path
            context.config.save!

            context.display.success("Clock in photo set to \"#{path}\"")
          end
        end
      end
    end
  end
end
