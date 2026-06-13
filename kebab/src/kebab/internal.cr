module Kebab
  # Internal-only — never raised from user code, never seen in `parse`'s
  # return type. Lets `initialize` unwind out of a deeply nested case
  # statement back to `self.parse`, which converts it to a returned value.
  # Using a dedicated internal class means `self.parse` rescues exactly this
  # class — not `Exception` or `Kebab::Error::Base` — so any other exception
  # (a converter bug, a Crystal error, a user `raise`) propagates normally
  # for the caller to debug.
  module Internal
    class ParseExit < ::Exception
      def initialize(@result : ::Kebab::Help | ::Kebab::Errors)
        super("internal — caught by Parseable.parse")
      end

      getter result : ::Kebab::Help | ::Kebab::Errors
    end
  end
end
