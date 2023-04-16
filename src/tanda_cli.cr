# shards
require "option_parser"

# internal
require "./configuration"
require "./current"
require "./utils/**"
require "./api/**"
require "./cli/**"

module Tanda::CLI
  extend self

  def main(args = ARGV)
    CLI::Parser.parse!(args)
  end
end

{% if flag?(:debug) %}
  require "./debug"
  Tanda::CLI::Debug.setup
{% end %}

{% unless flag?(:test) %}
  Tanda::CLI.main
{% end %}
