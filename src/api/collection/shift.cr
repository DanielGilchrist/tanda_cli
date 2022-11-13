require "../../types/shift"

module Tanda::CLI
  module API
    class Collection::Shift
      include Enumerable(Types::Shift)

      def self.from(response : HTTP::Client::Response, client : API::Client) : API::Result(self)
        result = if response.success?
          shifts = Array(Types::Shift).from_json(response.body)
          leave_request_ids = shifts.compact_map(&.leave_request_id)
          leave_requests_by_id = if leave_request_ids.any?
            leave_requests = client.leave_requests(ids: leave_request_ids).or do |error|
              return API::Result(self).new(error)
            end

            leave_requests.index_by(&.id)
          end

          if leave_requests_by_id && leave_requests_by_id.any?
            shifts.each do |shift|
              leave_request = leave_requests_by_id[shift.leave_request_id]?
              next if leave_request.nil?

              shift.set_leave_request!(leave_request)
            end
          end

          new(shifts)
        else
          Types::Error.from_json(response.body)
        end

        API::Result(self).new(result)
      end

      def initialize(@shifts : Array(Types::Shift)); end

      getter shifts : Array(Types::Shift)

      def each
        shifts.each { |shift| yield(shift) }
      end
    end
  end
end
