module Tanda::CLI
  module Utils
    module Mixins
      module PrettyTimes
        module PrettyMaybeStart
          abstract def start_time : ::Time?

          def pretty_start_time : String?
            start_time = self.start_time
            return if start_time.nil?

            Utils::Time.pretty_time(start_time)
          end
        end

        module PrettyMaybeFinish
          abstract def finish_time : ::Time?

          def pretty_finish_time : String?
            finish_time = self.finish_time
            return if finish_time.nil?

            Utils::Time.pretty_time(finish_time)
          end
        end

        module PrettyDate
          abstract def date : ::Time

          def pretty_date : String
            Utils::Time.pretty_date(date)
          end
        end

        macro included
          macro finished
            \{% if @type.has_method?(:start_time) %}
              include PrettyMaybeStart
            \{% end %}

            \{% if @type.has_method?(:finish_time) %}
              include PrettyMaybeFinish
            \{% end %}

            \{% if @type.has_method?(:date) %}
              include PrettyDate
            \{% end %}
          end
        end
      end
    end
  end
end
