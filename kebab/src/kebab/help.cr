module Kebab
  # A request for help text — produced when the user passes `--help`/`-h`/
  # `help`, or when a parent command without a chosen subcommand is parsed
  # with a non-required subcommand field. Help is a valid parse outcome, not
  # an error; the caller `case ... in`s it and prints `.text`.
  class Help
    def initialize(@text : String)
    end

    getter text : String
  end
end
