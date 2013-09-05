require 'benchmark'
require 'fast_safe_buffer'
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

REPS = 10        # Number of times to call render
TAGS = 300       # Number of ERB tags in template
TAG_SIZE = 3000  # Size of string inside ERB tags.

Benchmark.bmbm do |x|
  x.report("fast    ")  do
    RenderContext.fast!
    context = RenderContext.new
    REPS.times { context.render(TAGS, TAG_SIZE) }
  end
  x.report("orignal ")  do
    RenderContext.original!
    context = RenderContext.new
    REPS.times { context.render(TAGS, TAG_SIZE) }
  end
end