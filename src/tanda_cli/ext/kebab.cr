require "../../../kebab/src/kebab"
require "../error/interface"

class Kebab::Error::Base
  include TandaCLI::Error::Interface
end
