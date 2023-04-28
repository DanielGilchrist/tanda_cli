require "json"

class String
  def to_parsed_pretty_json
    begin
      JSON.parse(self)
    rescue JSON::ParseException
      self
    end.to_pretty_json
  end
end
