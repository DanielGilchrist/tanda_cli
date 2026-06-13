require "cling"

# Cling resolves subcommands before options are evaluated, so a space-separated
# option value ("clockin start --at 8:45") is treated as an unmatched subcommand
# and resolution fails for commands without positional arguments. Fall back to
# the current command so the value can be consumed by `get_in_position`.
module Cling::Executor
  private def self.resolve_command(command : Command, results : Array(Parser::Result)) : Command?
    arguments = results.select { |result| result.kind.argument? && !result.string? }
    return command if arguments.empty? || command.children.empty?

    if found_command = command.children.values.find(&.is?(arguments.first.value))
      results.shift
      resolve_command(found_command, results)
    else
      command
    end
  end
end
