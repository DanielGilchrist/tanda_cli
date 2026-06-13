require "../../kebab/src/kebab"
require "./error/base"

module TandaCLI
  module Converters
    # Turn a tanda domain parse result into a kebab one — preserves the rich
    # error description on the InvalidValue that kebab raises at the call site.
    def self.bridge(result : T | Error::Base) : T | Kebab::Error::Base forall T
      case result
      in T
        result
      in Error::Base
        Kebab::Error::Unparsable.new(result.error_description || result.error)
      end
    end
  end
end

require "./converters/*"
