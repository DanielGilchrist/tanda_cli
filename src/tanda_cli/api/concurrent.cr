require "./fatal_error"
require "./network_error"
require "./result"

module TandaCLI
  module API
    module Concurrent
      extend self

      macro all(*procs)
        {% for work, index in procs %}
          %channel{index} = Channel(typeof({{ work }}.call) | Exception).new(1)
          %work{index} = {{ work }}

          spawn do
            %outcome{index} = begin
              %work{index}.call
            rescue ex : Exception
              ex
            end

            %channel{index}.send(%outcome{index})
          end
        {% end %}

        Tuple.new(
          {% for work, index in procs %}
            begin
              %received{index} = %channel{index}.receive
              %received{index}.is_a?(Exception) ? raise %received{index} : %received{index}
            end,
          {% end %}
        )
      end

      def fetch(inputs : Array(T), &block : T -> Result(R)) : Array(Result(R)) forall T, R
        return Array(Result(R)).new if inputs.empty?

        channel = Channel(Tuple(Int32, Result(R) | Exception)).new(inputs.size)

        inputs.each_with_index do |input, index|
          spawn do
            outcome = begin
              block.call(input)
            rescue ex : Exception
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
