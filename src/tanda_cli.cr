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

  def try_parse_config!(config : Configuration)
    config.parse_config!
  rescue error
    {% if flag?(:debug) %}
      raise(error)
    {% else %}
      value = error.message.try(&.split("\n").first) if error.is_a?(JSON::SerializableError)
      reason = " (#{value})" if value
      Utils::Display.error("Invalid Config#{reason}")
      exit
    {% end %}
  end

  def main
    config = Configuration.new
    try_parse_config!(config)

    if config.staging?
      Utils::Display.warning("Running command on #{config.mode}\n")
    end

    CLI::Parser.new(config).parse!
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
