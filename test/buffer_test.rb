require File.dirname(__FILE__) + '/test_helper'

class BufferTest < Test::Unit::TestCase
  def setup
    @buffer = FastSafeBuffer.new
  end

  def test_initialize
    buffer = FastSafeBuffer.new("hi")
    assert_equal "hi", buffer.to_str
    
    @buffer << "muffin"
    buffer = FastSafeBuffer.new(@buffer)
    assert_equal @buffer.to_str, buffer.to_str
  end

  def test_size
    @buffer.concat "me"
    @buffer.concat "&you"

    assert_equal "me&amp;you".size, @buffer.size
    assert_equal "me&amp;you".size, @buffer.length
  end
  
  def test_size
    assert @buffer.empty?
    @buffer.concat "yo"
    assert ! @buffer.empty?
  end

  def test_concat
    @buffer << "hi"
    @buffer << " here"
    @buffer << " & there"

    assert_equal "hi here &amp; there", @buffer.to_str
  end

  def test_concat_buffer
    @buffer << FastSafeBuffer.new("hi")

    assert_equal "hi", @buffer.to_str
  end

  def test_safe_concat
    @buffer.safe_concat "me"
    @buffer.safe_concat " & you"

    assert_equal "me & you", @buffer.to_str
  end
  
  def test_concat_unsafe
    @buffer.safe_concat "unsafe".capitalize

    assert_equal "Unsafe", @buffer.to_str
  end

  def test_clone
    @buffer.concat "yo"

    buffer2 = @buffer.clone
    @buffer.concat "oops"
    
    assert buffer2.html_safe?
    assert_equal "yo", buffer2.to_str
  end

  def test_force_encoding
    @buffer.force_encoding("utf-8")

    assert_raise(EncodingError) { @buffer.force_encoding("ascii") }
  end
end