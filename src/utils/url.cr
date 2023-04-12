module Tanda::CLI
  module Utils
    module URL
      extend self

      record Error, message : String

      def validate(url : String) : URI | Error
        uri = URI.parse(url).normalize!
        Validator.new(uri).validate
      end

      private struct Validator
        VALID_HOSTS = [
          ".tanda.co",
          ".workforce.com",
        ]

        def initialize(@uri : URI); end

        def validate : URI | Error
          error = determine_error?
          return Error.new(error) if error

          uri
        end

        private getter uri : URI

        private def determine_error? : String?
          if uri.opaque?
            "Invalid URL"
          elsif !https?
            "URL must be prefixed with \"https://\""
          elsif query_params?
            "URL cannot contain query parameters"
          elsif invalid_host?
            "Host must contain #{VALID_HOSTS.join(" or ")}"
          end
        end

        private def https? : Bool
          uri.scheme == "https"
        end

        private def query_params?
          !!uri.query
        end

        private def invalid_host? : Bool
          host = uri.host
          return true if host.nil?

          VALID_HOSTS.none? { |valid_host| host.includes?(valid_host) }
        end
      end
    end
  end
end
