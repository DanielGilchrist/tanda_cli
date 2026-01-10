module TandaCLI
  module Error
    class PhotoTooLarge < Error::Base
      def initialize(photo_bytes : String)
        super("Photo too large", "photo must be under 1 MB (#{photo_bytes.bytesize} bytes)")
      end
    end
  end
end
