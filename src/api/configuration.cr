module Tanda::CLI
  module API
    class Configuration
      enum ServerCountry
        AU
        EU
        US
      end

      getter prefix : ServerCountry

      def initialize(prefix : ServerCountry)
        @prefix = prefix
      end

      def get_api_url : String
        prefix_string =
          case prefix
          when ServerCountry::AU
            "my"
          when ServerCountry::EU
            "eu"
          when ServerCountry::US
            "us"
          end

        "https://#{prefix_string}.tanda.co/api/v2"
      end
    end
  end
end
