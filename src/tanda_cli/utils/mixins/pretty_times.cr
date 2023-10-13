module TandaCLI
  module Utils
    module Mixins
      module PrettyTimes
        module PrettyMaybeStart
          def pretty_start_time : String?
            start_time = self.start_time
            return if start_time.nil?

            Utils::Time.pretty_time(start_time)
          end
        end

        module PrettyMaybeFinish
          def pretty_finish_time : String?
            finish_time = self.finish_time
            return if finish_time.nil?

            Utils::Time.pretty_time(finish_time)
          end
        end

        module PrettyDateTime
          def pretty_date_time : String
            Utils::Time.pretty_date_time(time)
          end
        end

        module PrettyDate
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

            \{% if @type.has_method?(:time) %}
              include PrettyDateTime
            \{% end %}
          end
        end
      end
    end
  end
end
