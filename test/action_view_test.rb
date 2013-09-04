require 'test_helper'
require "fast_safe_buffer/action_view"

class ActionViewTest < Test::Unit::TestCase
  include ActionView::Context

  def setup
    @view = ActionView::Base.new
  end

  def test_render
    output = @view.render(inline: "awe<%= 'some' %>")
    assert_equal "awesome", output
  end
end