module Tanda::CLI
  module API
    module Endpoints::Interface
      abstract def get(endpoint : String, query : TQuery? = nil) : HTTP::Client::Response
      abstract def post(endpoint : String, body : TBody) : HTTP::Client::Response
    end
  end
end
