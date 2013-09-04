require 'active_support/core_ext/string/output_safety'

require "fast_safe_buffer/version"
require "fast_safe_buffer_ext"

class FastSafeBuffer
  class SafeConcatError < StandardError
    def initialize
      super 'Could not concatenate to the buffer because it is not html safe.'
    end
  end

  def initialize(buffer=nil)
    concat buffer if buffer
  end

  # Aliases used in ERB
  alias :append= :<<

  def safe_concat(value)
    raise SafeConcatError unless html_safe?
    unsafe_concat(value)
  end
  alias :safe_append= :safe_concat

  def to_s
    to_str
  end

  def to_param
    to_str
  end

  def clone_empty
    self.class.new
  end

  def encode_with(coder)
    coder.represent_scalar nil, to_str
  end

  def force_encoding(encoding)
    encoding = Encoding.find(encoding)
    raise EncodingError.new("buffer only supports UTF-8 encoding") unless encoding == Encoding::UTF_8
    self
  end

  def encoding
    Encoding::UTF_8
  end

  def encode!
    # noop
    self
  end
end
