require "./base"

module Tanda::CLI
  module Error
    class UnsupportedPhotoFormat < Error::Base
      def initialize
        super("Unsupported format", "photo must be either a JPEG or PNG file.")
      end
    end
  end
end
