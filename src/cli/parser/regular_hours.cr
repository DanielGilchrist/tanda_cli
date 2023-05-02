module Tanda::CLI
  class CLI::Parser
    class RegularHours < APIParser
      def parse
        parser.on("determine", "Determine the regular hours for a user") do
          CLI::Commands::RegularHours::Determine.new(client).execute
        end

        parser.on("display", "Display the regular hours for a user") do
          # TODO
        end
      end
    end
  end
end
