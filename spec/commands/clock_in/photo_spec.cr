require "../../spec_helper"

private def with_photo_directory(& : String ->) : Nil
  directory = File.tempname("clockin_photos")
  Dir.mkdir_p(directory)

  begin
    yield directory
  ensure
    FileUtils.rm_rf(directory)
  end
end

private def with_home(home : String, & : ->) : Nil
  original_home = ENV["HOME"]?
  ENV["HOME"] = home

  begin
    yield
  ensure
    ENV["HOME"] = original_home
  end
end

private def write_photo(directory : String, name : String, size : Int32 = 10) : String
  path = File.join(directory, name)
  File.write(path, "x" * size)
  path
end

describe TandaCLI::Commands::ClockIn::Photo do
  describe TandaCLI::Commands::ClockIn::Photo::Set do
    it "Sets a photo path" do
      with_photo_directory do |directory|
        path = write_photo(directory, "photo.png")
        context = run(["clockin", "photo", "set", path])

        context.config.clockin_photo_path.should eq(path)
        context.stdout.to_s.should eq("Success: Clock in photo set to \"#{path}\"\n")
      end
    end

    it "Sets a directory path" do
      with_photo_directory do |directory|
        write_photo(directory, "photo.png")
        context = run(["clockin", "photo", "set", directory])

        context.config.clockin_photo_path.should eq(directory)
      end
    end

    it "Sets a path relative to the home directory" do
      with_photo_directory do |directory|
        write_photo(directory, "photo.png")

        with_home(directory) do
          context = run(["clockin", "photo", "set", "~/photo.png"])

          context.config.clockin_photo_path.should eq("~/photo.png")
          context.stdout.to_s.should eq("Success: Clock in photo set to \"~/photo.png\"\n")
        end
      end
    end

    it "Errors when the path doesn't exist" do
      context = run(["clockin", "photo", "set", "/does/not/exist.png"])

      context.exit_status.should eq(1)
      context.stderr.to_s.should eq("Error: Invalid photo path\n")
      context.config.clockin_photo_path.should be_nil
    end

    it "Errors when the photo format is unsupported" do
      with_photo_directory do |directory|
        path = write_photo(directory, "photo.gif")
        context = run(["clockin", "photo", "set", path])

        context.exit_status.should eq(1)
        context.config.clockin_photo_path.should be_nil
      end
    end

    it "Errors when the directory has no valid photos" do
      with_photo_directory do |directory|
        write_photo(directory, "notes.txt")
        context = run(["clockin", "photo", "set", directory])

        context.exit_status.should eq(1)
        context.config.clockin_photo_path.should be_nil
      end
    end
  end

  describe TandaCLI::Commands::ClockIn::Photo::View do
    it "Shows the configured photo" do
      with_photo_directory do |directory|
        path = write_photo(directory, "photo.png")
        context = run(["clockin", "photo", "set", path])

        TandaCLI::Commands::Main.execute(["clockin", "photo", "view"], context)

        context.stdout.to_s.should contain("Clock in photo: #{path}")
      end
    end

    it "Says nothing is set when there's no photo" do
      context = run(["clockin", "photo", "view"])
      context.stdout.to_s.should eq("No clock in photo set\n")
    end
  end

  describe TandaCLI::Commands::ClockIn::Photo::Clear do
    it "Clears the configured photo" do
      with_photo_directory do |directory|
        path = write_photo(directory, "photo.png")
        context = run(["clockin", "photo", "set", path])

        TandaCLI::Commands::Main.execute(["clockin", "photo", "clear"], context)

        context.config.clockin_photo_path.should be_nil
        context.stdout.to_s.should contain("Success: Clock in photo cleared")
      end
    end
  end

  describe TandaCLI::Commands::ClockIn::Photo::List do
    it "Says nothing is set when there's no photo" do
      context = run(["clockin", "photo", "list"])
      context.stdout.to_s.should eq("Info: No clock in photo set\n")
    end

    it "Warns when a single photo is set instead of a directory" do
      with_photo_directory do |directory|
        path = write_photo(directory, "photo.png")
        context = run(["clockin", "photo", "set", path])

        TandaCLI::Commands::Main.execute(["clockin", "photo", "list"], context)

        context.stdout.to_s.should contain("Warning: Directory not set for clock in photos ('#{path}')")
      end
    end

    it "Lists every photo in the directory" do
      with_photo_directory do |directory|
        valid = write_photo(directory, "a.png")
        invalid = write_photo(directory, "b.txt")
        context = run(["clockin", "photo", "set", directory])

        TandaCLI::Commands::Main.execute(["clockin", "photo", "list"], context)
        output = context.stdout.to_s

        output.should contain("Info: Photos for clock ins in '#{directory}' directory:")
        output.should contain(valid)
        output.should contain(invalid)
      end
    end

    it "Lists every photo in a directory relative to the home directory" do
      with_photo_directory do |directory|
        valid = write_photo(directory, "a.png")

        with_home(directory) do
          context = run(["clockin", "photo", "set", "~"])

          TandaCLI::Commands::Main.execute(["clockin", "photo", "list"], context)
          output = context.stdout.to_s

          output.should contain("Info: Photos for clock ins in '#{directory}' directory:")
          output.should contain(valid)
        end
      end
    end

    it "Filters to valid photos" do
      with_photo_directory do |directory|
        valid = write_photo(directory, "a.png")
        invalid = write_photo(directory, "b.txt")
        context = run(["clockin", "photo", "set", directory])

        TandaCLI::Commands::Main.execute(["clockin", "photo", "list", "--filter", "valid"], context)
        output = context.stdout.to_s

        output.should contain("Info: Valid photos for clock ins in '#{directory}' directory:")
        output.should contain(valid)
        output.should_not contain(invalid)
      end
    end

    it "Filters to invalid photos" do
      with_photo_directory do |directory|
        valid = write_photo(directory, "a.png")
        oversized = write_photo(directory, "b.png", TandaCLI::Models::Photo::ONE_MEGABYTE + 1)
        context = run(["clockin", "photo", "set", directory])

        TandaCLI::Commands::Main.execute(["clockin", "photo", "list", "-f", "invalid"], context)
        output = context.stdout.to_s

        output.should contain(oversized)
        output.should_not contain("#{valid}\n")
      end
    end

    it "Errors on an unknown filter" do
      context = run(["clockin", "photo", "list", "--filter", "nope"])

      context.exit_status.should eq(1)
      context.stderr.to_s.should eq("Error: Invalid 'filter' option 'nope'\n")
    end
  end
end
