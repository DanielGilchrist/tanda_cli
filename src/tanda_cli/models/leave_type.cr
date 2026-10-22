require "../error/ambiguous_leave_type"
require "../error/unknown_leave_type"

module TandaCLI
  module Models
    # A leave type the API has told us this user may take
    struct LeaveType
      SUFFIX = " Leave"

      def self.available(names : Array(String)) : Array(LeaveType)
        names
          .compact_map(&.strip.presence)
          .uniq!(&.downcase)
          .map { |name| new(name) }
      end

      def self.parse(input : String, available : Array(LeaveType)) : LeaveType | Error::Base
        wanted = input.strip.downcase
        names = available.map(&.name)

        exact = available.find { |type| type.name.downcase == wanted }
        return exact if exact

        matches = available.select(&.name.downcase.includes?(wanted))

        case matches.size
        when 0 then Error::UnknownLeaveType.new(input, names)
        when 1 then matches.first
        else        Error::AmbiguousLeaveType.new(input, matches.map(&.name))
        end
      end

      def initialize(@name : String) : Nil; end

      getter name : String

      def pretty : String
        @name.rchop(SUFFIX)
      end

      def to_s(io : IO) : Nil
        io << @name
      end
    end
  end
end
