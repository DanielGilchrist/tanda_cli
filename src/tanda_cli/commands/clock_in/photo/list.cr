module TandaCLI
  module Commands
    struct ClockIn
      struct Photo
        @[Kebab::Command(name: "list", summary: "List photos current used for clock ins if a directory has been set")]
        struct List
          include Kebab::Serialisable

          VALID_FILTER_COMMANDS = {"valid", "invalid"}

          @[Kebab::Option(short: 'f', description: "Filter photos by 'valid' or 'invalid'")]
          getter filter : String?

          def run(context : Context) : Nil
            display = context.display

            filter = self.filter
            if filter && invalid_filter_option?(filter)
              display.error!("Invalid 'filter' option '#{filter}'")
            end

            clockin_photo_path = context.config.clockin_photo_path
            return display.info("No clock in photo set") if clockin_photo_path.nil?

            case photo_or_dir = Models::PhotoPathParser.new(clockin_photo_path).parse
            in Models::Photo
              display.warning("Directory not set for clock in photos ('#{photo_or_dir.path}')")
            in Models::PhotoDirectory
              display_photos(display, photo_or_dir, filter)
            in Error::Base
              display.error!(photo_or_dir)
            end
          end

          private def display_photos(display : TandaCLI::Display, photo_directory : Models::PhotoDirectory, filter : String?)
            photos = photo_directory.photos

            if filter == "valid"
              photos.select!(&.valid?)
            end

            if filter == "invalid"
              photos.select!(&.invalid?)
            end

            path_text = "'#{photo_directory.path}'"

            if photos.empty?
              if filter
                display.info("No #{filter} photos in #{path_text} directory")
              else
                display.info("No photos in #{path_text} directory")
              end

              return
            end

            if filter
              display.info("#{filter.titleize} photos for clock ins in #{path_text} directory:")
            else
              display.info("Photos for clock ins in #{path_text} directory:")
            end

            photos.sort_by(&.path).each do |photo|
              display.puts photo.path
            end
          end

          private def invalid_filter_option?(filter) : Bool
            !VALID_FILTER_COMMANDS.includes?(filter)
          end
        end
      end
    end
  end
end
