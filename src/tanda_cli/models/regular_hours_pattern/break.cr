module TandaCLI
  module Models
    struct RegularHoursPattern
      struct Break
        def self.from?(schedule_break : API::Types::Schedule::Break) : Break?
          start_time = schedule_break.start_time
          finish_time = schedule_break.finish_time
          return if start_time.nil? || finish_time.nil?

          new(start_time, finish_time)
        end

        def initialize(@start_time : Time, @finish_time : Time); end

        getter start_time : Time
        getter finish_time : Time
      end
    end
  end
end
