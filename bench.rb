require 'benchmark'
require 'fast_output_buffer'
require 'action_view'
require 'action_view/buffers'

class RenderContext
  include ActionView::Context
  OriginalBuffer = ActionView::OutputBuffer

  def initialize
    @view = ActionView::Base.new
  end

  def self.original!
    silence_warnings do
      ActionView.const_set :OutputBuffer, OriginalBuffer
    end
  end
  
  def self.fast!
    silence_warnings do
      ActionView.const_set :OutputBuffer, FastSafeBuffer
    end
  end

  def render(times, size)
    @view.render(inline: "<%= 'x' * size %>\n" * times, locals: { size: size })
  end
end

REPS = 500                # Number of times to call render
TAGS =     [100, 100,  500,  500,  1000]  # Number of ERB tags in template
TAG_SIZE = [100, 2500, 2500, 5000, 1000]  # Size of string inside ERB tags.

#### Rehearsal ####
RenderContext.fast!
context = RenderContext.new
context.render(10, 10)
RenderContext.original!
context = RenderContext.new
context.render(10, 10)
###################

TAGS.size.times do |i|
  tags = TAGS[i]
  tag_size = TAG_SIZE[i]

  puts "-" * 60
  puts "#{tags} tags, #{tag_size} characters in tags, rendered #{REPS} times"
  puts

  Benchmark.bm do |x|
    x.report("FastSafeBuffer           ")  do
      RenderContext.fast!
      context = RenderContext.new
      REPS.times { context.render(tags, tag_size) }
    end
    x.report("ActionView::OutputBuffer ")  do
      RenderContext.original!
      context = RenderContext.new
      REPS.times { context.render(tags, tag_size) }
    end
  end
end