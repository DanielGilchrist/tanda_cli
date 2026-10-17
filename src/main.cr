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
  files: TandaCLI::Storage::Files.default
)

exit(context.exit_status)
