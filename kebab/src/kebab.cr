require "./kebab/**"

module Kebab
  VERSION = "0.1.0"

  annotation Command; end
  annotation Option; end
  annotation Argument; end
  annotation Subcommand; end

  def self.parse_error(description : String) : Error::Unparseable
    Error::Unparseable.new(description)
  end
end
