require "json"
require "file_utils"

require "./configuration/**"
require "./storage/abstract_file"
require "./error/invalid_config"
require "./error/invalid_start_of_week"

module TandaCLI
  class Configuration
    REPLACE_PROMPT = "Press enter to continue with a default config (this overwrites the file), or Ctrl+C to quit"

    def self.init(file : Storage::AbstractFile, input : Input, display : Display) : Configuration
      contents = file.read.presence
      return new(file) if contents.nil?

      begin
        new(file, Serialisable.from_json(contents))
      rescue ex
        {% if flag?(:raise_errors) %}
          raise(ex)
        {% else %}
          replace?(file, ex, input, display) ? nil : display.error!(Error::InvalidConfig.new(file.path))
        {% end %}
      end || new(file)
    end

    private def self.replace?(file : Storage::AbstractFile, ex : Exception, input : Input, display : Display) : Bool
      reason = ex.message.try(&.split("\n").first) if ex.is_a?(JSON::SerializableError) || ex.is_a?(JSON::ParseException)
      display.error(Error::InvalidConfig.new(file.path, reason))

      input.confirmed?(REPLACE_PROMPT)
    end

    def initialize(@file : Storage::AbstractFile, @serialisable : Serialisable = Serialisable.new) : Nil; end

    delegate :start_of_week,
      :start_of_week=,
      :pretty_start_of_week,
      :clockin_photo_path,
      :clockin_photo_path=,
      :treat_paid_breaks_as_unpaid?,
      :regular_hours_schedules,
      :replace_regular_hours_schedules!,
      :clear_regular_hours_schedules!,
      to: @serialisable

    def save! : Nil
      @file.write(@serialisable)
    end
  end
end
