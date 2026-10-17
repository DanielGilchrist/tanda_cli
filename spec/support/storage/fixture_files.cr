require "./fixture_file"

module Storage::FixtureFiles
  FIXTURE_PATH = "spec/fixtures"

  private alias EnvironmentName = TandaCLI::State::Serialisable::Environment::Name

  enum Fixture
    Default
    DefaultStaging
    InheritedStaging
    InvalidJson
    MondayStartOfWeek
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
    environments = EnvironmentName.values.to_h do |name|
      file = Storage::FixtureFile.load(fixture.path(name.to_s.downcase))

      {name, file.as(TandaCLI::Storage::AbstractFile)}
    end

    TandaCLI::Storage::Files.new(environments, Storage::FixtureFile.load(fixture.path("state")))
  end
end
