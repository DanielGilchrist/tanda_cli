require "./fixture_file"

module Storage::FixtureFiles
  FIXTURE_PATH = "spec/fixtures"

  enum Fixture
    Default
    DefaultStaging
    InheritedStaging
    InvalidJson
    MondayStartOfWeek
    NoCurrentUser
    NoRegularHours
    OvernightRegularHours
    Unauthenticated

    def directory : String
      "#{FIXTURE_PATH}/#{to_s.underscore}"
    end

    def path(file_name : String) : String
      "#{directory}/#{file_name}.json"
    end
  end

  def self.load(fixture : Fixture) : TandaCLI::Storage::Files
    configurations = TandaCLI::Environment.values.to_h do |mode|
      file = Storage::FixtureFile.load(fixture.path(mode.to_s.downcase))

      {mode, file.as(TandaCLI::Storage::AbstractFile)}
    end

    TandaCLI::Storage::Files.new(configurations, Storage::FixtureFile.load(fixture.path("state")))
  end
end
