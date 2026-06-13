require "./base"

module Kebab
  module Error
    class RepeatedOption < Error::Base
      def initialize(name : String)
        super("Repeated option!", "\"#{name}\" was given more than once.")
      end
    end
  end
end
