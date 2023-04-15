module Tanda::CLI
  module Error
    class Base < Exception
      def initialize(@title : String, @message : String)
        super("#{title}: #{message}")
      end

      getter title : String
    end
  end
end
