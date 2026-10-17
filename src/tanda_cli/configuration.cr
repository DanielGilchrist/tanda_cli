require "json"
require "file_utils"

require "./configuration/**"
require "./storage/abstract_file"
require "./error/invalid_start_of_week"

module TandaCLI
  class Configuration
    def self.init(file : Storage::AbstractFile, display : Display) : Configuration
      contents = file.read.presence
      return new(file) if contents.nil?

      begin
        new(file, Serialisable.from_json(contents))
      rescue ex
        {% if flag?(:raise_errors) %}
          raise(ex)
        {% else %}
          reason = ex.message.try(&.split("\n").first) if ex.is_a?(JSON::SerializableError) || ex.is_a?(JSON::ParseException)
          # TODO: Better handle this potential once-off case
          display.error("Invalid Config!", reason) do |sub_errors|
            sub_errors << "If you want to try and fix the config manually press Ctrl+C to quit\n"
            sub_errors << "Press enter if you want to proceed with a default config (this will override the existing config)"
          end
          gets # don't proceed unless user wants us to
          nil
        {% end %}
      end || new(file)
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
