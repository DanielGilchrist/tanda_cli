require "./base"

module TandaCLI
  module Error
    class EditorFailed < Error::Base
      def initialize(command : String, status : Process::Status) : Nil
        super(
          "Editor \"#{command}\" exited with status #{status.exit_code}",
          "Regular hours not updated.",
        )
      end
    end
  end
end
