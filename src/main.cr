require "./tanda_cli"

{% if flag?(:debug) %}
  TandaCLI::Debug.setup
{% end %}

TandaCLI.main(
  args: ARGV,
  stdout: STDOUT,
  stdin: STDIN,
  stderr: STDERR,
  config_file: TandaCLI::Configuration::File.new
)
