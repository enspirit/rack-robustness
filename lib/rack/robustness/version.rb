# Kept free of any require, so that the gemspec can read the version without
# loading Rack: doing so would activate a Rack version before Bundler has had
# a chance to constrain it.
module Rack
  class Robustness
    VERSION = "2.0.0".freeze
  end
end
