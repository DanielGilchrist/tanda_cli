require "json"

module TandaCLI
  enum Environment
    Production
    Staging
    Custom

    def to_json(builder : JSON::Builder) : Nil
      builder.string(to_s.downcase)
    end

    def file_name : String
      "#{to_s.downcase}.json"
    end
  end
end
