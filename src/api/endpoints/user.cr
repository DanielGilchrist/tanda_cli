require "../client"

module Tanda::CLI
  module API
    module Endpoints::User
      def user(id : Int32, show_regular_hours : Bool = false, force : Bool = false) : API::Result(Types::User)
        response = get("/users/#{id}", query: {
          "show_regular_hours" => show_regular_hours.to_s,
        }.tap do |options|
          options["cache_key"] = Random.rand(1000).to_s if force
        end)

        API::Result(Types::User).from(response)
      end
    end
  end
end
