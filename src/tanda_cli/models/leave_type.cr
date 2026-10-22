require "../api/types/leave_type"
require "../error/ambiguous_leave_type"
require "../error/unknown_leave_type"

module TandaCLI
  module Models
    # A leave type the API has told us this user may take
    struct LeaveType
      SUFFIX = " Leave"

      def self.available(types : Array(API::Types::LeaveType)) : Array(LeaveType)
        types
          .reject(&.name.blank?)
          .uniq!(&.name.downcase)
          .map { |type| new(type.name, type.day_length) }
      end

      def self.named(name : String) : LeaveType
        new(name, nil)
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

      private def initialize(@name : String, @day_length : Time::Span?) : Nil; end

      getter name : String
      getter day_length : Time::Span?

      def pretty : String
        @name.rchop(SUFFIX)
      end

      def to_s(io : IO) : Nil
        io << @name
      end
    end
  end
end
