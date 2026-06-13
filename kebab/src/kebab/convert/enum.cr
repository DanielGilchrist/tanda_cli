require "../error/invalid_value"

module Kebab
  module Convert
    module Enum(T)
      def self.parse(input : String) : T | ::Kebab::Error::InvalidValue
        T.parse?(input) || ::Kebab.invalid_value("expected one of: #{T.names.map(&.downcase).join(", ")}")
      end
    end
  end
end
