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
        end

        parser.on("staging", "Set mode to staging") do
          config.mode = "staging"
          config.save!

          Utils::Display.success("Successfully set mode to staging!")
        end

        parser.on("--custom=CUSTOM", "Set mode to custom URL") do |custom|
          if custom.blank?
            Utils::Display.error("Must pass an argument to custom")
            exit
          end

          uri = Configuration.validate_url(custom)

          if uri.is_a?(String)
            Utils::Display.error(uri, custom)
            exit
          end

          uri_string = uri.to_s
          config.mode = uri_string
          config.save!

          Utils::Display.success("Successfully saved custom url!", uri_string)
          exit
        end

        parser.on("current", "View currently set mode") do
          puts "Mode is currently set to #{config.mode}"
        end
      end

      private getter parser
      private getter config

      private def invalid_host?(uri : URI) : Bool
        host = uri.host
        return true if host.nil?


      end
    end
  end
end
