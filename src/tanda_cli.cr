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

  def main
    CLI::Parser.parse!
  end
end

{% if flag?(:debug) %}
  require "./debug"
  Tanda::CLI::Debug.setup
{% end %}

# TODO: Test `Tanda::CLI.main`
{% unless flag?(:test) %}
  Tanda::CLI.main
{% end %}
