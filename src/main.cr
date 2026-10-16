require "./tanda_cli"

{% if flag?(:debug) %}
  TandaCLI::Debug.setup
{% end %}

TandaCLI::Spinner.enabled = STDERR.tty?

context = TandaCLI.main(
  args: ARGV,
  stdout: STDOUT,
  stdin: STDIN,
  stderr: STDERR,
  config_file: TandaCLI::Configuration::File.new
)

exit(context.exit_status)
