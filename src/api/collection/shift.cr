require "../../types/shift"

module Tanda::CLI
  module API
    class Collection::Shift
      include Enumerable(Types::Shift)

      def self.from(response : HTTP::Client::Response, client : API::Client) : API::Result(self)
        result = response.success? ? parse_shifts(response, client) : Types::Error.from_json(response.body)
        API::Result(self).new(result)
      end

      private def self.parse_shifts(response : HTTP::Client::Response, client : API::Client) : self | Types::Error
        shifts = Array(Types::Shift).from_json(response.body)
        leave_request_ids = shifts.compact_map(&.leave_request_id)
        return new(shifts) if leave_request_ids.empty?

        leave_requests_by_id = client.leave_requests(ids: leave_request_ids).or { |error| return error }.index_by(&.id)

        if !leave_requests_by_id.empty?
          shifts.each do |shift|
            leave_request = leave_requests_by_id[shift.leave_request_id]?
            next if leave_request.nil?

            shift.set_leave_request!(leave_request)
          end
        end

        new(shifts)
      end

      def initialize(@shifts : Array(Types::Shift)); end

      getter shifts : Array(Types::Shift)

      def each
        shifts.each { |shift| yield(shift) }
      end
    end
  end
end
