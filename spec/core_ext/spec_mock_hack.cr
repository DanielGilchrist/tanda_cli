# this is a hack for shards that check if we're in test mode with `@top_level.has_constant?("Spec")`
# as we don't use the built-in `Spec` module and instead use `Spectator`
module Spec; end
