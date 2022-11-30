module Tanda::CLI
  module Utils
    module Mixins
      module PrettyStartFinish
        abstract def start_time : ::Time?
        abstract def finish_time : ::Time?

        def pretty_start_time : String?
          start_time = self.start_time
          return if start_time.nil?

          Utils::Time.pretty_time(start_time)
        end

        def pretty_finish_time : String?
          finish_time = self.finish_time
          return if finish_time.nil?

          Utils::Time.pretty_time(finish_time)
        end
      end
    end
  end
end
