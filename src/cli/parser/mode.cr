require "uri"

module Tanda::CLI
  class CLI::Parser
    class Mode
      def initialize(@parser : OptionParser, @config : Configuration); end

      def parse
        parser.on("production", "Set mode to production") do
          config.mode = "production"
          config.save!

          Utils::Display.success("Successfully set mode to production!")
          exit
        end

        parser.on("staging", "Set mode to staging") do
          config.mode = "staging"
          config.save!

          Utils::Display.success("Successfully set mode to staging!")
          exit
        end

        parser.on("--custom=CUSTOM", "Set mode to custom URL") do |custom|
          Utils::Display.error!("Must pass an argument to custom") if custom.blank?

          uri = Configuration.validate_url(custom)

          Utils::Display.error!(uri, custom) if uri.is_a?(String)

          uri_string = uri.to_s
          config.mode = uri_string
          config.save!

          Utils::Display.success("Successfully set custom url", uri_string)
          exit
        end

        parser.on("current", "View currently set mode") do
          mode = config.mode

          if { "production", "staging" }.includes?(mode)
            puts "Mode is currently set to #{mode}"
          else
            puts "Mode is set to a custom URL (#{mode})"
          end

          exit
        end
      end

      private getter parser
      private getter config
    end
  end
end
