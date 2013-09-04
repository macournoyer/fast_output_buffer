require "bundler/setup"
Bundler.require(:default, :test)

require "test/unit"
require "mocha"

class Test::Unit::TestCase
  # include Mocha::API # fix mocha API not being included in minitest
end