require "./client"
require "./result"

module TandaCLI
  module API
    module Concurrent
      def self.fetch(inputs : Array(T), &block : T -> Result(R)) : Array(Result(R)) forall T, R
        return Array(Result(R)).new if inputs.empty?

        channel = Channel(Tuple(Int32, Result(R) | Exception)).new(inputs.size)

        inputs.each_with_index do |input, index|
          spawn do
            outcome = begin
              block.call(input)
            rescue ex : Client::NetworkError | Client::FatalAPIError
              ex
            end
            channel.send({index, outcome})
          end
        end

        ordered = Array(Tuple(Int32, Result(R) | Exception)).new(inputs.size) { channel.receive }
        ordered.sort_by!(&.first)

        ordered.map do |(_, outcome)|
          case outcome
          in Result(R)
            outcome
          in Exception
            raise outcome
          end
        end
      end
    end
  end
end
