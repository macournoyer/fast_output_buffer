require 'test_helper'
require "fast_output_buffer/action_view"

class ActionViewTest < Test::Unit::TestCase
  include ActionView::Context

  def setup
    @view = ActionView::Base.new
  end

  def test_replace_output_buffer
    assert_equal FastSafeBuffer, ActionView::OutputBuffer
  end

  def test_render
    output = @view.render(inline: "awe<%= 'some' %>", locals: { var: 'some' })
    assert_equal "awesome", output
  end
end