require "./error/invalid_value"
require "./error/missing_argument"
require "./error/missing_command"
require "./error/missing_option"
require "./error/missing_value"
require "./error/unexpected_argument"
require "./error/unknown_command"
require "./error/unknown_option"

module Kebab
  # The closed set of parse errors. `parse` returns one of these (alongside the
  # parsed struct or `Help`), so callers exhaustively `case ... in` on each
  # outcome — no `Error::Base` escape hatch in the public surface.
  alias Errors = Error::InvalidValue |
                 Error::MissingArgument |
                 Error::MissingCommand |
                 Error::MissingOption |
                 Error::MissingValue |
                 Error::UnexpectedArgument |
                 Error::UnknownCommand |
                 Error::UnknownOption
end
