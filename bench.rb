require 'benchmark'
require 'fast_safe_buffer'

N = 10000000

s = ActiveSupport::SafeBuffer.new
b = FastSafeBuffer.new

Benchmark.bmbm do |x|
  x.report("orignal ")  { N.times { s << "x" }; s = ActiveSupport::SafeBuffer.new }
  x.report("fast    ")  { N.times { b << "x" }; b = FastSafeBuffer.new }
end