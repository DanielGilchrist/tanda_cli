module TandaCLI
  module Commands
    class ClockIn
      class Photo
        class List < Commands::Base
          VALID_FILTER_COMMANDS = {"valid", "invalid"}

          def setup_
            @name = "list"
            @summary = @description = "List photos current used for clock ins if a directory has been set"

            add_option 'f', "filter", type: :single, required: false, description: "Filter photos by 'valid' or 'invalid'"
          end

          def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
            filter = options.get?("filter").try(&.as_s)

            if filter && invalid_filter_option?(filter)
              on_invalid_option("Invalid 'filter' option '#{filter}'")
            end

            clockin_photo_path = Current.config.clockin_photo_path
            return Utils::Display.info("No clock in photo set") if clockin_photo_path.nil?

            case photo_or_dir = Models::PhotoPathParser.new(clockin_photo_path).parse
            in Models::Photo
              Utils::Display.warning("Directory not set for clock in photos ('#{photo_or_dir.path}')")
            in Models::PhotoDirectory
              display_photos(photo_or_dir, filter)
            in Error::Base
              photo_or_dir.display!
            end
          end

          private def display_photos(photo_directory : Models::PhotoDirectory, filter : String?)
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
                Utils::Display.info("No #{filter} photos in #{path_text} directory")
              else
                Utils::Display.info("No photos in #{path_text} directory")
              end

              return
            end

            if filter
              Utils::Display.info("#{filter.titleize} photos for clock ins in #{path_text} directory:")
            else
              Utils::Display.info("Photos for clock ins in #{path_text} directory:")
            end

            photos.sort_by(&.path).each do |photo|
              puts photo.path
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
