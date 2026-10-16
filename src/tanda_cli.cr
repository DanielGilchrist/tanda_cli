# internal
require "./tanda_cli/**"

module TandaCLI
  extend self

  def main(args : Array(String), stdin : IO, stdout : IO, stderr : IO, config_file : Configuration::AbstractFile) : Context
    display = Display.new(stdout, stderr)
    input = Input.new(stdin, display)

    Context.new(config_file, display, input).tap do |context|
      Commands::Main.execute(args, context)
    rescue ex : ExitProgram
      context.exit_status = ex.status
    rescue ex
      {% if flag?(:raise_errors) %}
        raise ex
      {% else %}
        context.display.error(ex.message || "An error occurred")
        context.exit_status = ExitProgram::FAILURE
      {% end %}
    end
  end

  def exit!(status : Int32 = ExitProgram::SUCCESS) : NoReturn
    raise(ExitProgram.new(status))
  end

  def fail! : NoReturn
    exit!(ExitProgram::FAILURE)
  end
end
