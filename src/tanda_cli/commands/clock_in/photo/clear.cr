module TandaCLI
  module Commands
    struct ClockIn
      struct Photo
        @[Kebab::Command(name: "clear", summary: "Clear set clockin photo or directory")]
        struct Clear
          include Kebab::Serialisable

          def run(context : Context) : Nil
            context.config.clockin_photo_path = nil
            context.config.save!

            context.display.success("Clock in photo cleared")
          end
        end
      end
    end
  end
end
