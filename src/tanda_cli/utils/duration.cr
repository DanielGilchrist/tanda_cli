module TandaCLI
  module Utils
    module Duration
      extend self

      def compact(span : ::Time::Span) : String
        hours = span.total_hours.to_i
        minutes = span.minutes.abs

        return "#{hours}h" if minutes.zero?
        return "#{minutes}m" if hours.zero?

        "#{hours}h #{minutes}m"
      end
    end
  end
end
