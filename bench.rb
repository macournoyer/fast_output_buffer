require 'benchmark'
require 'fast_safe_buffer'

N = 10000000

s = ActiveSupport::SafeBuffer.new
b = FastSafeBuffer.new

Benchmark.bmbm do |x|
  # x.report("string ")  { N.times { s.concat "x" }; s = "" }
  # x.report("array  ")  { N.times { a << "x" }; a = [] }
  x.report("orignal ")  { N.times { s << "x" }; s = ActiveSupport::SafeBuffer.new }
  x.report("fast    ")  { N.times { b << "x" }; b = FastSafeBuffer.new }
end